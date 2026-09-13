using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;
using Portal.DTOs.Notes;

namespace Portal.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class NotesController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;

    public NotesController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    private string? GetCurrentUserId() =>
        User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

    [HttpGet]
    public async Task<ActionResult<IEnumerable<NoteDto>>> GetNotes([FromQuery] Guid? projectId)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie. Log opnieuw in." });

        var allNotes = (await _unitOfWork.Notes.GetAllAsync()).ToList();

        // Haal projecten op om overerving van rechten te controleren
        var accessibleProjectIds = (await _unitOfWork.Projects.GetAllAsync())
            .Where(p => p.OwnerId == currentUserId || p.SharedWithUsers.Any(u => u.Id == currentUserId))
            .Select(p => p.Id)
            .ToHashSet();

        var userNotes = allNotes.Where(n =>
            // 1. Zelf eigenaar van de notitie
            n.OwnerId == currentUserId
            // 2. Direct gedeeld met de user
            || n.SharedWithUsers.Any(u => u.Id == currentUserId)
            // 3. Notitie valt onder een project dat van jou is of met jou gedeeld is
            || (n.ProjectId.HasValue && accessibleProjectIds.Contains(n.ProjectId.Value))
        );

        if (projectId.HasValue)
        {
            userNotes = userNotes.Where(n => n.ProjectId == projectId.Value);
        }

        var dtos = userNotes.Select(n => new NoteDto
        {
            Id = n.Id,
            Title = n.Title,
            Content = n.Content,
            ProjectId = n.ProjectId,
            CreatedAt = n.CreatedAt
        });

        return Ok(dtos);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<NoteDto>> GetNote(Guid id)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var note = await _unitOfWork.Notes.GetByIdAsync(id);
        if (note == null) 
            return NotFound(new { message = "Notitie niet gevonden." });

        var hasAccess = note.OwnerId == currentUserId || note.SharedWithUsers.Any(u => u.Id == currentUserId);

        if (!hasAccess && note.ProjectId.HasValue)
        {
            var project = await _unitOfWork.Projects.GetByIdAsync(note.ProjectId.Value);
            if (project != null && (project.OwnerId == currentUserId || project.SharedWithUsers.Any(u => u.Id == currentUserId)))
            {
                hasAccess = true;
            }
        }

        if (!hasAccess)
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Je hebt geen toegang tot deze notitie." });

        return Ok(new NoteDto
        {
            Id = note.Id,
            Title = note.Title,
            Content = note.Content,
            ProjectId = note.ProjectId,
            CreatedAt = note.CreatedAt
        });
    }

    [HttpPost]
    public async Task<ActionResult<NoteDto>> CreateNote(CreateNoteDto dto)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        if (string.IsNullOrWhiteSpace(dto.Title))
            return BadRequest(new { message = "Titel van de notitie is verplicht." });

        if (dto.ProjectId.HasValue)
        {
            var project = await _unitOfWork.Projects.GetByIdAsync(dto.ProjectId.Value);
            if (project == null) 
                return NotFound(new { message = "Het gekoppelde project bestaat niet." });

            if (project.OwnerId != currentUserId && !project.SharedWithUsers.Any(u => u.Id == currentUserId))
                return StatusCode(StatusCodes.Status403Forbidden, new { message = "Je hebt geen rechten om notities toe te voegen aan dit project." });
        }

        var note = new Note
        {
            Title = dto.Title.Trim(),
            Content = dto.Content,
            ProjectId = dto.ProjectId,
            OwnerId = currentUserId
        };

        await _unitOfWork.Notes.AddAsync(note);
        await _unitOfWork.CompleteAsync();

        return CreatedAtAction(nameof(GetNote), new { id = note.Id }, new NoteDto
        {
            Id = note.Id,
            Title = note.Title,
            Content = note.Content,
            ProjectId = note.ProjectId,
            CreatedAt = note.CreatedAt
        });
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<NoteDto>> UpdateNote(Guid id, UpdateNoteDto dto)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var note = await _unitOfWork.Notes.GetByIdAsync(id);
        if (note == null) 
            return NotFound(new { message = "Notitie niet gevonden." });

        var hasAccess = note.OwnerId == currentUserId || note.SharedWithUsers.Any(u => u.Id == currentUserId);
        if (!hasAccess && note.ProjectId.HasValue)
        {
            var project = await _unitOfWork.Projects.GetByIdAsync(note.ProjectId.Value);
            if (project != null && (project.OwnerId == currentUserId || project.SharedWithUsers.Any(u => u.Id == currentUserId)))
            {
                hasAccess = true;
            }
        }

        if (!hasAccess)
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Je hebt geen rechten om deze notitie te wijzigen." });

        if (dto.ProjectId.HasValue)
        {
            var targetProject = await _unitOfWork.Projects.GetByIdAsync(dto.ProjectId.Value);
            if (targetProject == null) 
                return NotFound(new { message = "Het geselecteerde project bestaat niet." });

            if (targetProject.OwnerId != currentUserId && !targetProject.SharedWithUsers.Any(u => u.Id == currentUserId))
                return StatusCode(StatusCodes.Status403Forbidden, new { message = "Je hebt geen rechten om een notitie aan dit project te koppelen." });
        }

        note.Title = dto.Title.Trim();
        note.Content = dto.Content;
        note.ProjectId = dto.ProjectId;

        _unitOfWork.Notes.Update(note);
        await _unitOfWork.CompleteAsync();

        return Ok(new NoteDto
        {
            Id = note.Id,
            Title = note.Title,
            Content = note.Content,
            ProjectId = note.ProjectId,
            CreatedAt = note.CreatedAt
        });
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteNote(Guid id)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var note = await _unitOfWork.Notes.GetByIdAsync(id);
        if (note == null) 
            return NotFound(new { message = "Notitie niet gevonden." });

        // Verwijderen mag alleen door de eigenaar van de notitie of de project-eigenaar
        var canDelete = note.OwnerId == currentUserId;
        if (!canDelete && note.ProjectId.HasValue)
        {
            var project = await _unitOfWork.Projects.GetByIdAsync(note.ProjectId.Value);
            if (project != null && project.OwnerId == currentUserId)
            {
                canDelete = true;
            }
        }

        if (!canDelete)
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Alleen de eigenaar kan deze notitie verwijderen." });

        _unitOfWork.Notes.Delete(note);
        await _unitOfWork.CompleteAsync();

        return NoContent();
    }
}