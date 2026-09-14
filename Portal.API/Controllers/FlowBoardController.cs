using System.Security.Claims;
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

    private string? GetCurrentUserId() =>
        User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

    private async Task<bool> UserHasBoardAccess(Guid boardId, string userId)
    {
        return await _context.KanbanBoards
            .Include(b => b.Project)
                .ThenInclude(p => p!.SharedWithUsers)
            .AnyAsync(b => b.Id == boardId && (
                b.Project == null 
                || b.Project.OwnerId == userId 
                || b.Project.SharedWithUsers.Any(u => u.Id == userId)
            ));
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<KanbanCardDto>>> GetCards([FromQuery] Guid boardId)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        if (!await UserHasBoardAccess(boardId, currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Geen toegang tot dit FlowBoard." });

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
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        if (string.IsNullOrWhiteSpace(dto.Title))
            return BadRequest(new { message = "Kaarttitel is verplicht." });

        if (!await UserHasBoardAccess(dto.BoardId, currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Geen schrijfrechten op dit FlowBoard." });

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
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var card = await _unitOfWork.KanbanCards.GetByIdAsync(id);
        if (card == null) return NotFound(new { message = "Kaart niet gevonden." });

        if (!await UserHasBoardAccess(card.BoardId, currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Geen rechten om kaarten op dit bord te verplaatsen." });

        card.Status = dto.Status;
        card.UpdatedAt = DateTime.UtcNow;

        _unitOfWork.KanbanCards.Update(card);
        await _unitOfWork.CompleteAsync();

        return Ok();
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<KanbanCardDto>> UpdateCard(Guid id, [FromBody] UpdateKanbanCardDto dto)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var card = await _context.KanbanCards
            .Include(c => c.Labels)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (card == null) return NotFound(new { message = "Kaart niet gevonden." });

        if (!await UserHasBoardAccess(card.BoardId, currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Geen bewerkrechten op dit FlowBoard." });

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
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var card = await _unitOfWork.KanbanCards.GetByIdAsync(id);
        if (card == null) return NotFound(new { message = "Kaart niet gevonden." });

        if (!await UserHasBoardAccess(card.BoardId, currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Geen rechten om kaarten op dit bord te wissen." });

        _unitOfWork.KanbanCards.Delete(card);
        await _unitOfWork.CompleteAsync();

        return NoContent();
    }
}