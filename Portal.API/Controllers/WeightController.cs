using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Portal.Data;
using Portal.Domain.Entities;
using Portal.DTOs.Utils;

namespace Portal.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class WeightController : ControllerBase
{
    private readonly PortalDbContext _db;

    public WeightController(PortalDbContext db)
    {
        _db = db;
    }

    private Guid GetUserId() => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet]
    public async Task<ActionResult<List<WeightLogDto>>> GetAll()
    {
        var uid = GetUserId();
        var logs = await _db.WeightLogs
            .Where(w => w.UserId == uid)
            .OrderByDescending(w => w.Timestamp)
            .Select(w => new WeightLogDto
            {
                Id = w.Id,
                WeightKg = w.WeightKg,
                Timestamp = w.Timestamp,
                TimeSlot = w.TimeSlot
            })
            .ToListAsync();

        return Ok(logs);
    }

    [HttpPost]
    public async Task<ActionResult<WeightLogDto>> Create(CreateWeightLogDto dto)
    {
        var log = new WeightLog
        {
            UserId = GetUserId(),
            WeightKg = dto.WeightKg,
            Timestamp = dto.Timestamp,
            TimeSlot = dto.TimeSlot
        };

        _db.WeightLogs.Add(log);
        await _db.SaveChangesAsync();

        return Ok(new WeightLogDto
        {
            Id = log.Id,
            WeightKg = log.WeightKg,
            Timestamp = log.Timestamp,
            TimeSlot = log.TimeSlot
        });
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var uid = GetUserId();
        var item = await _db.WeightLogs.FirstOrDefaultAsync(w => w.Id == id && w.UserId == uid);
        if (item == null) return NotFound();

        _db.WeightLogs.Remove(item);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}