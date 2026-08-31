using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Portal.Data;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;
using Portal.DTOs.Kanban;

namespace Portal.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class BoardsController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly PortalDbContext _context;

    public BoardsController(IUnitOfWork unitOfWork, PortalDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<KanbanBoardDto>>> GetBoards([FromQuery] Guid? projectId)
    {
        var query = _context.KanbanBoards
            .Include(b => b.Cards)
            .AsNoTracking();

        var boards = projectId.HasValue
            ? await query.Where(b => b.ProjectId == projectId.Value).ToListAsync()
            : await query.Where(b => b.ProjectId == null).ToListAsync();

        var dtos = boards.Select(b => new KanbanBoardDto
        {
            Id = b.Id,
            Title = b.Title,
            Description = b.Description,
            ProjectId = b.ProjectId,
            CreatedAt = b.CreatedAt,
            CardCount = b.Cards.Count
        });

        return Ok(dtos);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<KanbanBoardDto>> GetBoard(Guid id)
    {
        var board = await _context.KanbanBoards
            .Include(b => b.Cards)
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.Id == id);

        if (board == null) return NotFound("Bord niet gevonden.");

        return Ok(new KanbanBoardDto
        {
            Id = board.Id,
            Title = board.Title,
            Description = board.Description,
            ProjectId = board.ProjectId,
            CreatedAt = board.CreatedAt,
            CardCount = board.Cards.Count
        });
    }

    [HttpPost]
    public async Task<ActionResult<KanbanBoardDto>> CreateBoard([FromBody] CreateKanbanBoardDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Title))
            return BadRequest("Bordtitel is verplicht.");

        var board = new KanbanBoard
        {
            Title = dto.Title.Trim(),
            Description = dto.Description,
            ProjectId = dto.ProjectId
        };

        await _unitOfWork.KanbanBoards.AddAsync(board);
        await _unitOfWork.CompleteAsync();

        return Ok(new KanbanBoardDto
        {
            Id = board.Id,
            Title = board.Title,
            Description = board.Description,
            ProjectId = board.ProjectId,
            CreatedAt = board.CreatedAt,
            CardCount = 0
        });
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteBoard(Guid id)
    {
        var board = await _unitOfWork.KanbanBoards.GetByIdAsync(id);
        if (board == null) return NotFound("Bord niet gevonden.");

        _unitOfWork.KanbanBoards.Delete(board);
        await _unitOfWork.CompleteAsync();

        return NoContent();
    }
}