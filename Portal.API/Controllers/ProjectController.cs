using Microsoft.AspNetCore.Authorization;
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

    public ProjectController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProjectDto>>> GetProjects()
    {
        var projects = (await _unitOfWork.Projects.GetAllAsync()).ToList();
        var allNotes = (await _unitOfWork.Notes.GetAllAsync()).ToList();
        var allReminders = (await _unitOfWork.Reminders.GetAllAsync()).ToList();

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
        var project = await _unitOfWork.Projects.GetByIdAsync(id);
        if (project == null) return NotFound("Project niet gevonden.");

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
        var project = new Project
        {
            Title = dto.Title,
            Description = dto.Description,
            RepositoryUrl = dto.RepositoryUrl
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

    [HttpPost("{projectId:guid}/notes")]
    public async Task<ActionResult<NoteDto>> AddNoteToProject(Guid projectId, CreateNoteForProjectDto dto)
    {
        var project = await _unitOfWork.Projects.GetByIdAsync(projectId);
        if (project == null) return NotFound("Project niet gevonden.");

        var note = new Note
        {
            Title = dto.Title,
            Content = dto.Content,
            ProjectId = projectId
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
        var project = await _unitOfWork.Projects.GetByIdAsync(projectId);
        if (project == null) return NotFound("Project niet gevonden.");

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
        var project = await _unitOfWork.Projects.GetByIdAsync(id);
        if (project == null) return NotFound("Project niet gevonden.");

        _unitOfWork.Projects.Delete(project);
        await _unitOfWork.CompleteAsync();

        return NoContent();
    }
}