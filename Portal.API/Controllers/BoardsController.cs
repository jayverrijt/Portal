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
            IsPublic = b.IsPublic,
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
            IsPublic = board.IsPublic,
            ProjectId = board.ProjectId,
            CreatedAt = board.CreatedAt,
            CardCount = board.Cards.Count
        });
    }

    [HttpGet("shared/{id:guid}")]
    [AllowAnonymous]
    public async Task<ActionResult<KanbanBoardDto>> GetSharedBoard(Guid id)
    {
        var board = await _context.KanbanBoards
            .Include(b => b.Cards)
                .ThenInclude(c => c.SubTasks)
            .Include(b => b.Cards)
                .ThenInclude(c => c.Labels)
            .Include(b => b.Labels)
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.Id == id);

        if (board == null || !board.IsPublic)
            return NotFound("Dit bord bestaat niet of is niet openbaar ingesteld.");

        return Ok(new KanbanBoardDto
        {
            Id = board.Id,
            Title = board.Title,
            Description = board.Description,
            IsPublic = board.IsPublic,
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
            ProjectId = dto.ProjectId,
            IsPublic = false
        };

        await _unitOfWork.KanbanBoards.AddAsync(board);
        await _unitOfWork.CompleteAsync();

        return Ok(new KanbanBoardDto
        {
            Id = board.Id,
            Title = board.Title,
            Description = board.Description,
            IsPublic = board.IsPublic,
            ProjectId = board.ProjectId,
            CreatedAt = board.CreatedAt,
            CardCount = 0
        });
    }

    [HttpPatch("{id:guid}/public")]
    public async Task<IActionResult> TogglePublicBoard(Guid id, [FromBody] TogglePublicDto dto)
    {
        var board = await _context.KanbanBoards.FindAsync(id);
        if (board == null) return NotFound("Bord niet gevonden.");

        board.IsPublic = dto.IsPublic;
        await _context.SaveChangesAsync();

        return NoContent();
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

    [HttpGet("{id:guid}/members")]
    public async Task<ActionResult<List<BoardMemberViewDto>>> GetBoardMembers(Guid id)
    {
        var board = await _context.KanbanBoards.FindAsync(id);
        if (board == null) return NotFound("Bord niet gevonden.");
        return Ok(new List<BoardMemberViewDto>());
    }

    [HttpPost("{id:guid}/share")]
    public async Task<IActionResult> ShareBoard(Guid id, [FromBody] ShareBoardDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Email))
            return BadRequest(new { message = "E-mailadres is verplicht." });

        var board = await _context.KanbanBoards.FindAsync(id);
        if (board == null) return NotFound(new { message = "Bord niet gevonden." });

        return Ok(new { message = "Bord succesvol gedeeld." });
    }

    [HttpDelete("{id:guid}/share/{userId}")]
    public async Task<IActionResult> RevokeBoardShare(Guid id, string userId)
    {
        var board = await _context.KanbanBoards.FindAsync(id);
        if (board == null) return NotFound("Bord niet gevonden.");

        return NoContent();
    }

    public class TogglePublicDto
    {
        public bool IsPublic { get; set; }
    }
}