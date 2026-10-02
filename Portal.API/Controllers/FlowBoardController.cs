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
            .Include(c => c.SubTasks)
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
            MoscowPriority = c.MoscowPriority,
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
            }).ToList(),
            SubTasks = c.SubTasks.Select(st => new SubTaskDto
            {
                Id = st.Id,
                Title = st.Title,
                Status = st.Status,
                CardId = st.CardId
            }).ToList()
        });

        return Ok(dtos);
    }

    // --- PUBLIEKE ENDPOINT VOOR GASTEN (READ-ONLY) ---
    [HttpGet("shared/{boardId:guid}")]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<KanbanCardDto>>> GetSharedBoardCards(Guid boardId)
    {
        var board = await _context.KanbanBoards
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.Id == boardId);

        if (board == null || !board.IsPublic)
            return NotFound(new { message = "Dit bord is niet openbaar of bestaat niet." });

        var cards = await _context.KanbanCards
            .Where(c => c.BoardId == boardId)
            .Include(c => c.Labels)
            .Include(c => c.SubTasks)
            .AsNoTracking()
            .ToListAsync();

        var dtos = cards.Select(c => new KanbanCardDto
        {
            Id = c.Id,
            Title = c.Title,
            Description = c.Description,
            Status = c.Status,
            SprintNumber = c.SprintNumber,
            MoscowPriority = c.MoscowPriority,
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
            }).ToList(),
            SubTasks = c.SubTasks.Select(st => new SubTaskDto
            {
                Id = st.Id,
                Title = st.Title,
                Status = st.Status,
                CardId = st.CardId
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
            MoscowPriority = dto.MoscowPriority,
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

        if (dto.SubTasks.Any())
        {
            foreach (var stDto in dto.SubTasks)
            {
                card.SubTasks.Add(new SubTask
                {
                    Title = stDto.Title.Trim(),
                    Status = stDto.Status
                });
            }
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
            MoscowPriority = card.MoscowPriority,
            BoardId = card.BoardId,
            DueDate = card.DueDate,
            CreatedAt = card.CreatedAt,
            Labels = card.Labels.Select(l => new BoardLabelDto
            {
                Id = l.Id,
                Name = l.Name,
                ColorHex = l.ColorHex,
                BoardId = l.BoardId
            }).ToList(),
            SubTasks = card.SubTasks.Select(st => new SubTaskDto
            {
                Id = st.Id,
                Title = st.Title,
                Status = st.Status,
                CardId = st.CardId
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
            .Include(c => c.SubTasks)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (card == null) return NotFound(new { message = "Kaart niet gevonden." });

        if (!await UserHasBoardAccess(card.BoardId, currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Geen bewerkrechten op dit FlowBoard." });

        card.Title = dto.Title.Trim();
        card.Description = dto.Description;
        card.Status = dto.Status;
        card.SprintNumber = dto.SprintNumber;
        card.MoscowPriority = dto.MoscowPriority;
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
            MoscowPriority = card.MoscowPriority,
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
            }).ToList(),
            SubTasks = card.SubTasks.Select(st => new SubTaskDto
            {
                Id = st.Id,
                Title = st.Title,
                Status = st.Status,
                CardId = st.CardId
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

    // --- SubTask Endpoints ---

    [HttpPost("cards/{cardId:guid}/subtasks")]
    public async Task<ActionResult<SubTaskDto>> CreateSubTask(Guid cardId, [FromBody] CreateSubTaskDto dto)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId)) return Unauthorized();

        var card = await _context.KanbanCards
            .Include(c => c.Board)
            .ThenInclude(b => b.Project)
            .FirstOrDefaultAsync(c => c.Id == cardId);

        if (card == null) return NotFound(new { message = "Use Case kaart niet gevonden." });

        if (!await UserHasBoardAccess(card.BoardId, currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden);

        var subTask = new SubTask
        {
            Title = dto.Title.Trim(),
            Status = dto.Status,
            CardId = cardId
        };

        _context.SubTasks.Add(subTask);
        await _context.SaveChangesAsync();

        return Ok(new SubTaskDto
        {
            Id = subTask.Id,
            Title = subTask.Title,
            Status = subTask.Status,
            CardId = subTask.CardId
        });
    }

    [HttpPatch("subtasks/{subTaskId:guid}/status")]
    public async Task<IActionResult> UpdateSubTaskStatus(Guid subTaskId, [FromBody] UpdateSubTaskDto dto)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId)) return Unauthorized();

        var subTask = await _context.SubTasks
            .Include(st => st.Card)
            .ThenInclude(c => c.Board)
            .ThenInclude(b => b.Project)
            .FirstOrDefaultAsync(st => st.Id == subTaskId);

        if (subTask == null) return NotFound(new { message = "Subtask niet gevonden." });

        if (!await UserHasBoardAccess(subTask.Card.BoardId, currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden);

        if (!string.IsNullOrWhiteSpace(dto.Title))
        {
            subTask.Title = dto.Title.Trim();
        }
        subTask.Status = dto.Status;
        subTask.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new SubTaskDto
        {
            Id = subTask.Id,
            Title = subTask.Title,
            Status = subTask.Status,
            CardId = subTask.CardId
        });
    }

    [HttpDelete("subtasks/{subTaskId:guid}")]
    public async Task<IActionResult> DeleteSubTask(Guid subTaskId)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId)) return Unauthorized();

        var subTask = await _context.SubTasks
            .Include(st => st.Card)
            .ThenInclude(c => c.Board)
            .ThenInclude(b => b.Project)
            .FirstOrDefaultAsync(st => st.Id == subTaskId);

        if (subTask == null) return NotFound(new { message = "Subtask niet gevonden." });

        if (!await UserHasBoardAccess(subTask.Card.BoardId, currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden);

        _context.SubTasks.Remove(subTask);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}