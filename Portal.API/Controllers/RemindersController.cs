using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;
using Portal.DTOs.Reminders;

namespace Portal.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class RemindersController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;

    public RemindersController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ReminderDto>>> GetReminders([FromQuery] Guid? projectId, [FromQuery] bool? isCompleted)
    {
        var reminders = await _unitOfWork.Reminders.GetAllAsync();

        if (projectId.HasValue)
        {
            reminders = reminders.Where(r => r.ProjectId == projectId.Value);
        }

        if (isCompleted.HasValue)
        {
            reminders = reminders.Where(r => r.IsCompleted == isCompleted.Value);
        }

        var dtos = reminders.Select(r => new ReminderDto
        {
            Id = r.Id,
            Title = r.Title,
            Description = r.Description,
            DueDate = r.DueDate,
            IsCompleted = r.IsCompleted,
            ProjectId = r.ProjectId,
            CreatedAt = r.CreatedAt
        });

        return Ok(dtos);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ReminderDto>> GetReminder(Guid id)
    {
        var reminder = await _unitOfWork.Reminders.GetByIdAsync(id);
        if (reminder == null) return NotFound("Reminder niet gevonden.");

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

    [HttpPost]
    public async Task<ActionResult<ReminderDto>> CreateReminder(CreateReminderDto dto)
    {
        if (dto.ProjectId.HasValue)
        {
            var projectExists = await _unitOfWork.Projects.GetByIdAsync(dto.ProjectId.Value);
            if (projectExists == null) return BadRequest("Opgegeven project bestaat niet.");
        }

        var reminder = new Reminder
        {
            Title = dto.Title,
            Description = dto.Description,
            DueDate = dto.DueDate,
            IsCompleted = false,
            ProjectId = dto.ProjectId
        };

        await _unitOfWork.Reminders.AddAsync(reminder);
        await _unitOfWork.CompleteAsync();

        return CreatedAtAction(nameof(GetReminder), new { id = reminder.Id }, new ReminderDto
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

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<ReminderDto>> UpdateReminder(Guid id, UpdateReminderDto dto)
    {
        var reminder = await _unitOfWork.Reminders.GetByIdAsync(id);
        if (reminder == null) return NotFound("Reminder niet gevonden.");

        if (dto.ProjectId.HasValue)
        {
            var projectExists = await _unitOfWork.Projects.GetByIdAsync(dto.ProjectId.Value);
            if (projectExists == null) return BadRequest("Opgegeven project bestaat niet.");
        }

        reminder.Title = dto.Title;
        reminder.Description = dto.Description;
        reminder.DueDate = dto.DueDate;
        reminder.IsCompleted = dto.IsCompleted;
        reminder.ProjectId = dto.ProjectId;

        _unitOfWork.Reminders.Update(reminder);
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

    [HttpPatch("{id:guid}/toggle")]
    public async Task<ActionResult<ReminderDto>> ToggleReminderCompletion(Guid id)
    {
        var reminder = await _unitOfWork.Reminders.GetByIdAsync(id);
        if (reminder == null) return NotFound("Reminder niet gevonden.");

        reminder.IsCompleted = !reminder.IsCompleted;

        _unitOfWork.Reminders.Update(reminder);
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
    public async Task<IActionResult> DeleteReminder(Guid id)
    {
        var reminder = await _unitOfWork.Reminders.GetByIdAsync(id);
        if (reminder == null) return NotFound("Reminder niet gevonden.");

        _unitOfWork.Reminders.Delete(reminder);
        await _unitOfWork.CompleteAsync();

        return NoContent();
    }
}