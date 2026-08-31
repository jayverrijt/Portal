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
public class FlowBoardController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly PortalDbContext _context;

    public FlowBoardController(IUnitOfWork unitOfWork, PortalDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<KanbanCardDto>>> GetCards([FromQuery] Guid boardId)
    {
        var cards = await _context.KanbanCards
            .Include(c => c.Labels)
            .AsNoTracking()
            .Where(c => c.BoardId == boardId)
            .ToListAsync();

        var dtos = cards.Select(c => new KanbanCardDto
        {
            Id = c.Id,
            Title = c.Title,
            Description = c.Description,
            Status = c.Status,
            SprintNumber = c.SprintNumber,
            BoardId = c.BoardId,
            DueDate = c.DueDate,
            CreatedAt = c.CreatedAt,
            UpdatedAt = c.UpdatedAt,
            Labels = c.Labels.Select(l => new BoardLabelDto
            {
                Id = l.Id,
                Name = l.Name,
                ColorHex = l.ColorHex,
                BoardId = l.BoardId
            }).ToList()
        });

        return Ok(dtos);
    }

    [HttpPost]
    public async Task<ActionResult<KanbanCardDto>> CreateCard([FromBody] CreateKanbanCardDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Title))
            return BadRequest("Kaarttitel is verplicht.");

        var board = await _unitOfWork.KanbanBoards.GetByIdAsync(dto.BoardId);
        if (board == null) return NotFound("Bord niet gevonden.");

        var card = new KanbanCard
        {
            Title = dto.Title.Trim(),
            Description = dto.Description,
            Status = dto.Status,
            SprintNumber = dto.SprintNumber,
            BoardId = dto.BoardId,
            DueDate = dto.DueDate
        };

        if (dto.LabelIds.Any())
        {
            var labels = await _context.BoardLabels
                .Where(l => dto.LabelIds.Contains(l.Id) && l.BoardId == dto.BoardId)
                .ToListAsync();
            card.Labels = labels;
        }

        await _unitOfWork.KanbanCards.AddAsync(card);
        await _unitOfWork.CompleteAsync();

        return Ok(new KanbanCardDto
        {
            Id = card.Id,
            Title = card.Title,
            Description = card.Description,
            Status = card.Status,
            SprintNumber = card.SprintNumber,
            BoardId = card.BoardId,
            DueDate = card.DueDate,
            CreatedAt = card.CreatedAt,
            Labels = card.Labels.Select(l => new BoardLabelDto
            {
                Id = l.Id,
                Name = l.Name,
                ColorHex = l.ColorHex,
                BoardId = l.BoardId
            }).ToList()
        });
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> UpdateCardStatus(Guid id, [FromBody] UpdateKanbanCardStatusDto dto)
    {
        var card = await _unitOfWork.KanbanCards.GetByIdAsync(id);
        if (card == null) return NotFound("Kaart niet gevonden.");

        card.Status = dto.Status;
        card.UpdatedAt = DateTime.UtcNow;

        _unitOfWork.KanbanCards.Update(card);
        await _unitOfWork.CompleteAsync();

        return Ok();
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<KanbanCardDto>> UpdateCard(Guid id, [FromBody] UpdateKanbanCardDto dto)
    {
        var card = await _context.KanbanCards
            .Include(c => c.Labels)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (card == null) return NotFound("Kaart niet gevonden.");

        card.Title = dto.Title.Trim();
        card.Description = dto.Description;
        card.Status = dto.Status;
        card.SprintNumber = dto.SprintNumber;
        card.DueDate = dto.DueDate;
        card.UpdatedAt = DateTime.UtcNow;

        card.Labels.Clear();
        if (dto.LabelIds.Any())
        {
            var selectedLabels = await _context.BoardLabels
                .Where(l => dto.LabelIds.Contains(l.Id) && l.BoardId == card.BoardId)
                .ToListAsync();
            foreach (var label in selectedLabels)
            {
                card.Labels.Add(label);
            }
        }

        await _context.SaveChangesAsync();

        return Ok(new KanbanCardDto
        {
            Id = card.Id,
            Title = card.Title,
            Description = card.Description,
            Status = card.Status,
            SprintNumber = card.SprintNumber,
            BoardId = card.BoardId,
            DueDate = card.DueDate,
            CreatedAt = card.CreatedAt,
            UpdatedAt = card.UpdatedAt,
            Labels = card.Labels.Select(l => new BoardLabelDto
            {
                Id = l.Id,
                Name = l.Name,
                ColorHex = l.ColorHex,
                BoardId = l.BoardId
            }).ToList()
        });
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteCard(Guid id)
    {
        var card = await _unitOfWork.KanbanCards.GetByIdAsync(id);
        if (card == null) return NotFound("Kaart niet gevonden.");

        _unitOfWork.KanbanCards.Delete(card);
        await _unitOfWork.CompleteAsync();

        return NoContent();
    }
}