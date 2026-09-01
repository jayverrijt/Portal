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
public class ShortLinksController : ControllerBase
{
    private readonly PortalDbContext _db;

    public ShortLinksController(PortalDbContext db)
    {
        _db = db;
    }

    [Authorize]
    [HttpGet]
    public async Task<ActionResult<List<ShortLinkDto>>> GetAll()
    {
        var uid = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var list = await _db.ShortLinks
            .Where(s => s.UserId == uid)
            .OrderByDescending(s => s.CreatedAt)
            .Select(s => new ShortLinkDto
            {
                Id = s.Id,
                OriginalUrl = s.OriginalUrl,
                Slug = s.Slug,
                ShortUrl = $"https://portal.jayverrijt.nl/go/{s.Slug}",
                Clicks = s.Clicks,
                CreatedAt = s.CreatedAt
            })
            .ToListAsync();

        return Ok(list);
    }

    [Authorize]
    [HttpPost]
    public async Task<ActionResult<ShortLinkDto>> Create(CreateShortLinkDto dto)
    {
        var uid = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var slug = string.IsNullOrWhiteSpace(dto.Slug)
            ? Guid.NewGuid().ToString("N")[..6]
            : dto.Slug.Trim().ToLower().Replace(" ", "-");

        if (await _db.ShortLinks.AnyAsync(s => s.Slug == slug))
            return BadRequest("Slug is al in gebruik.");

        var link = new ShortLink
        {
            UserId = uid,
            OriginalUrl = dto.OriginalUrl.Trim(),
            Slug = slug
        };

        _db.ShortLinks.Add(link);
        await _db.SaveChangesAsync();

        return Ok(new ShortLinkDto
        {
            Id = link.Id,
            OriginalUrl = link.OriginalUrl,
            Slug = link.Slug,
            ShortUrl = $"https://portal.jayverrijt.nl/go/{link.Slug}",
            Clicks = 0,
            CreatedAt = link.CreatedAt
        });
    }

    [Authorize]
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var uid = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var link = await _db.ShortLinks.FirstOrDefaultAsync(s => s.Id == id && s.UserId == uid);
        if (link == null) return NotFound();

        _db.ShortLinks.Remove(link);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [AllowAnonymous]
    [HttpGet("/go/{slug}")]
    public async Task<IActionResult> RedirectToUrl(string slug)
    {
        var link = await _db.ShortLinks.FirstOrDefaultAsync(s => s.Slug == slug.ToLower());
        if (link == null) return NotFound("Shortlink niet gevonden.");

        link.Clicks++;
        await _db.SaveChangesAsync();

        return Redirect(link.OriginalUrl);
    }
}