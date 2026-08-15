using Cronos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;
using Portal.DTOs.ScheduledTasks;

namespace Portal.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ScheduledTasksController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;

    public ScheduledTasksController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ScheduledTaskDto>>> GetTasks()
    {
        var tasks = await _unitOfWork.ScheduledTasks.GetAllAsync();

        var dtos = tasks.Select(t => new ScheduledTaskDto
        {
            Id = t.Id,
            Name = t.Name,
            CronExpression = t.CronExpression,
            LastRunAt = t.LastRunAt,
            NextRunAt = t.NextRunAt,
            IsActive = t.IsActive,
            CreatedAt = t.CreatedAt
        });

        return Ok(dtos);
    }

    [HttpPost]
    public async Task<ActionResult<ScheduledTaskDto>> CreateTask(CreateScheduledTaskDto dto)
    {
        CronExpression expression;
        try
        {
            expression = CronExpression.Parse(dto.CronExpression);
        }
        catch (Exception)
        {
            return BadRequest("Ongeldige Cron-expressie. Gebruik het standaard 5-of-6-delige Cron formaat.");
        }

        var nextRun = expression.GetNextOccurrence(DateTime.UtcNow);
        if (!nextRun.HasValue)
        {
            return BadRequest("De opgegeven Cron-expressie heeft geen toekomstige uitvoerdatum.");
        }

        var task = new ScheduledTask
        {
            Name = dto.Name,
            CronExpression = dto.CronExpression,
            NextRunAt = nextRun.Value,
            IsActive = true
        };

        await _unitOfWork.ScheduledTasks.AddAsync(task);
        await _unitOfWork.CompleteAsync();

        return CreatedAtAction(nameof(GetTasks), new { id = task.Id }, new ScheduledTaskDto
        {
            Id = task.Id,
            Name = task.Name,
            CronExpression = task.CronExpression,
            LastRunAt = task.LastRunAt,
            NextRunAt = task.NextRunAt,
            IsActive = task.IsActive,
            CreatedAt = task.CreatedAt
        });
    }

    [HttpPatch("{id:guid}/toggle")]
    public async Task<ActionResult<ScheduledTaskDto>> ToggleTask(Guid id)
    {
        var task = await _unitOfWork.ScheduledTasks.GetByIdAsync(id);
        if (task == null) return NotFound("Scheduled task niet gevonden.");

        task.IsActive = !task.IsActive;

        if (task.IsActive)
        {
            var expression = CronExpression.Parse(task.CronExpression);
            var nextRun = expression.GetNextOccurrence(DateTime.UtcNow);
            if (nextRun.HasValue)
            {
                task.NextRunAt = nextRun.Value;
            }
        }

        _unitOfWork.ScheduledTasks.Update(task);
        await _unitOfWork.CompleteAsync();

        return Ok(new ScheduledTaskDto
        {
            Id = task.Id,
            Name = task.Name,
            CronExpression = task.CronExpression,
            LastRunAt = task.LastRunAt,
            NextRunAt = task.NextRunAt,
            IsActive = task.IsActive,
            CreatedAt = task.CreatedAt
        });
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteTask(Guid id)
    {
        var task = await _unitOfWork.ScheduledTasks.GetByIdAsync(id);
        if (task == null) return NotFound("Scheduled task niet gevonden.");

        _unitOfWork.ScheduledTasks.Delete(task);
        await _unitOfWork.CompleteAsync();

        return NoContent();
    }
}