using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;
using Portal.DTOs.Notes;
using Portal.DTOs.Projects;
using Portal.DTOs.Reminders;

namespace Portal.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ProjectController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly UserManager<ApplicationUser> _userManager;

    public ProjectController(IUnitOfWork unitOfWork, UserManager<ApplicationUser> userManager)
    {
        _unitOfWork = unitOfWork;
        _userManager = userManager;
    }

    private string? GetCurrentUserId() =>
        User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProjectDto>>> GetProjects()
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie. Log opnieuw in." });

        // Alleen projecten van de user zelf óf die expliciet met hem gedeeld zijn
        var allProjects = await _unitOfWork.Projects.GetAllAsync();
        var projects = allProjects
            .Where(p => p.OwnerId == currentUserId || p.SharedWithUsers.Any(u => u.Id == currentUserId))
            .ToList();

        var allowedProjectIds = projects.Select(p => p.Id).ToHashSet();

        var allNotes = (await _unitOfWork.Notes.GetAllAsync())
            .Where(n => n.ProjectId.HasValue && allowedProjectIds.Contains(n.ProjectId.Value))
            .ToList();

        var allReminders = (await _unitOfWork.Reminders.GetAllAsync())
            .Where(r => r.ProjectId.HasValue && allowedProjectIds.Contains(r.ProjectId.Value))
            .ToList();

        var dtos = projects.Select(p => new ProjectDto
        {
            Id = p.Id,
            Title = p.Title,
            Description = p.Description,
            RepositoryUrl = p.RepositoryUrl,
            CreatedAt = p.CreatedAt,
            UpdatedAt = p.UpdatedAt,
            Notes = allNotes.Where(n => n.ProjectId == p.Id).Select(n => new NoteDto
            {
                Id = n.Id,
                Title = n.Title,
                Content = n.Content,
                ProjectId = n.ProjectId,
                CreatedAt = n.CreatedAt
            }).ToList(),
            Reminders = allReminders.Where(r => r.ProjectId == p.Id).Select(r => new ReminderDto
            {
                Id = r.Id,
                Title = r.Title,
                Description = r.Description,
                DueDate = r.DueDate,
                IsCompleted = r.IsCompleted,
                ProjectId = r.ProjectId,
                CreatedAt = r.CreatedAt
            }).ToList()
        });

        return Ok(dtos);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ProjectDto>> GetProject(Guid id)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var project = await _unitOfWork.Projects.GetByIdAsync(id);
        if (project == null) 
            return NotFound(new { message = "Project niet gevonden." });

        // Autorisatiecheck
        if (project.OwnerId != currentUserId && !project.SharedWithUsers.Any(u => u.Id == currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Je hebt geen toegang tot dit project." });

        var notes = await _unitOfWork.Notes.FindAsync(n => n.ProjectId == id);
        var reminders = await _unitOfWork.Reminders.FindAsync(r => r.ProjectId == id);

        var dto = new ProjectDto
        {
            Id = project.Id,
            Title = project.Title,
            Description = project.Description,
            RepositoryUrl = project.RepositoryUrl,
            CreatedAt = project.CreatedAt,
            UpdatedAt = project.UpdatedAt,
            Notes = notes.Select(n => new NoteDto
            {
                Id = n.Id,
                Title = n.Title,
                Content = n.Content,
                ProjectId = n.ProjectId,
                CreatedAt = n.CreatedAt
            }).ToList(),
            Reminders = reminders.Select(r => new ReminderDto
            {
                Id = r.Id,
                Title = r.Title,
                Description = r.Description,
                DueDate = r.DueDate,
                IsCompleted = r.IsCompleted,
                ProjectId = r.ProjectId,
                CreatedAt = r.CreatedAt
            }).ToList()
        };

        return Ok(dto);
    }

    [HttpPost]
    public async Task<ActionResult<ProjectDto>> CreateProject(CreateProjectDto dto)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        if (string.IsNullOrWhiteSpace(dto.Title))
            return BadRequest(new { message = "Titel van het project is verplicht." });

        var project = new Project
        {
            Title = dto.Title.Trim(),
            Description = dto.Description,
            RepositoryUrl = dto.RepositoryUrl,
            OwnerId = currentUserId
        };

        await _unitOfWork.Projects.AddAsync(project);
        await _unitOfWork.CompleteAsync();

        return CreatedAtAction(nameof(GetProject), new { id = project.Id }, new ProjectDto
        {
            Id = project.Id,
            Title = project.Title,
            Description = project.Description,
            RepositoryUrl = project.RepositoryUrl,
            CreatedAt = project.CreatedAt
        });
    }

    [HttpPost("{projectId:guid}/share")]
    public async Task<IActionResult> ShareProject(Guid projectId, [FromBody] ShareProjectRequest request)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var project = await _unitOfWork.Projects.GetByIdAsync(projectId);
        if (project == null)
            return NotFound(new { message = "Project niet gevonden." });

        if (project.OwnerId != currentUserId)
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Alleen de eigenaar kan dit project delen." });

        if (string.IsNullOrWhiteSpace(request.Email))
            return BadRequest(new { message = "E-mailadres is verplicht." });

        var targetUser = await _userManager.FindByEmailAsync(request.Email.Trim());
        if (targetUser == null)
            return NotFound(new { message = $"Geen account gevonden met e-mailadres '{request.Email}'." });

        if (targetUser.Id == currentUserId)
            return BadRequest(new { message = "Je bent al eigenaar van dit project." });

        if (project.SharedWithUsers.Any(u => u.Id == targetUser.Id))
            return BadRequest(new { message = $"Dit project is al gedeeld met {targetUser.Email}." });

        project.SharedWithUsers.Add(targetUser);
        _unitOfWork.Projects.Update(project);
        await _unitOfWork.CompleteAsync();

        return Ok(new { message = $"Project succesvol gedeeld met {targetUser.Email}." });
    }

    [HttpPost("{projectId:guid}/notes")]
    public async Task<ActionResult<NoteDto>> AddNoteToProject(Guid projectId, CreateNoteForProjectDto dto)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var project = await _unitOfWork.Projects.GetByIdAsync(projectId);
        if (project == null) 
            return NotFound(new { message = "Project niet gevonden." });

        if (project.OwnerId != currentUserId && !project.SharedWithUsers.Any(u => u.Id == currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Geen schrijfrechten op dit project." });

        var note = new Note
        {
            Title = dto.Title,
            Content = dto.Content,
            ProjectId = projectId,
            OwnerId = currentUserId
        };

        await _unitOfWork.Notes.AddAsync(note);
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

    [HttpPost("{projectId:guid}/reminders")]
    public async Task<ActionResult<ReminderDto>> AddReminderToProject(Guid projectId, CreateReminderForProjectDto dto)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var project = await _unitOfWork.Projects.GetByIdAsync(projectId);
        if (project == null) 
            return NotFound(new { message = "Project niet gevonden." });

        if (project.OwnerId != currentUserId && !project.SharedWithUsers.Any(u => u.Id == currentUserId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Geen schrijfrechten op dit project." });

        var reminder = new Reminder
        {
            Title = dto.Title,
            Description = dto.Description,
            DueDate = dto.DueDate,
            IsCompleted = false,
            ProjectId = projectId
        };

        await _unitOfWork.Reminders.AddAsync(reminder);
        await _unitOfWork.CompleteAsync();

        return Ok(new ReminderDto
        {
            Id = reminder.Id,
            Title = reminder.Title,
            Description = reminder.Description,
            DueDate = reminder.DueDate,
            IsCompleted = reminder.IsCompleted,
            ProjectId = reminder.ProjectId,
            CreatedAt = reminder.CreatedAt
        });
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteProject(Guid id)
    {
        var currentUserId = GetCurrentUserId();
        if (string.IsNullOrEmpty(currentUserId))
            return Unauthorized(new { message = "Geen geldige sessie." });

        var project = await _unitOfWork.Projects.GetByIdAsync(id);
        if (project == null) 
            return NotFound(new { message = "Project niet gevonden." });

        if (project.OwnerId != currentUserId)
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Alleen de eigenaar kan dit project verwijderen." });

        _unitOfWork.Projects.Delete(project);
        await _unitOfWork.CompleteAsync();

        return NoContent();
    }
}

public record ShareProjectRequest(string Email);