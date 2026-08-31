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
public class PastebinController : ControllerBase
{
    private readonly PortalDbContext _db;

    public PastebinController(PortalDbContext db)
    {
        _db = db;
    }

    private Guid GetUserId() => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet]
    public async Task<ActionResult<PastebinDto>> Get()
    {
        var uid = GetUserId();
        var buffer = await _db.PastebinBuffers.FirstOrDefaultAsync(p => p.UserId == uid);
        return Ok(new PastebinDto
        {
            Content = buffer?.Content ?? string.Empty,
            UpdatedAt = buffer?.UpdatedAt ?? DateTime.UtcNow
        });
    }

    [HttpPost]
    public async Task<IActionResult> Save([FromBody] PastebinDto dto)
    {
        var uid = GetUserId();
        var buffer = await _db.PastebinBuffers.FirstOrDefaultAsync(p => p.UserId == uid);

        if (buffer == null)
        {
            buffer = new PastebinBuffer
            {
                UserId = uid,
                Content = dto.Content,
                UpdatedAt = DateTime.UtcNow
            };
            _db.PastebinBuffers.Add(buffer);
        }
        else
        {
            buffer.Content = dto.Content;
            buffer.UpdatedAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync();
        return Ok();
    }
}