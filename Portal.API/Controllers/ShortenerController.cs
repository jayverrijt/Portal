using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Portal.Data;
using Portal.Domain.Entities;
using Portal.DTOs.Shortener;

namespace Portal.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ShortenerController : ControllerBase
{
    private readonly PortalDbContext _db;

    public ShortenerController(PortalDbContext db)
    {
        _db = db;
    }

    // 1. Publiek endpoint: Iedereen kan een shortcode resolven (geen login vereist)
    [AllowAnonymous]
    [HttpGet("{code}")]
    public async Task<IActionResult> ResolveCode(string code)
    {
        var link = await _db.ShortenedUrls.FirstOrDefaultAsync(u => u.Code.ToLower() == code.ToLower());
        if (link == null)
        {
            return NotFound($"Geen link gevonden voor code '{code}'.");
        }

        link.Clicks++;
        await _db.SaveChangesAsync();

        return Ok(link.OriginalUrl);
    }

    // 2. Overzicht van alle links (voor in het beheerpaneel/utils)
    [Authorize]
    [HttpGet]
    public async Task<ActionResult<List<ShortUrlDto>>> GetAll()
    {
        var links = await _db.ShortenedUrls
            .OrderByDescending(u => u.CreatedAt)
            .Select(u => new ShortUrlDto(u.Id, u.Code, u.OriginalUrl, u.Clicks, u.CreatedAt))
            .ToListAsync();

        return Ok(links);
    }

    // 3. Nieuwe short URL aanmaken
    [Authorize]
    [HttpPost]
    public async Task<ActionResult<ShortUrlDto>> Create([FromBody] CreateShortUrlDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.OriginalUrl))
        {
            return BadRequest("Oorspronkelijke URL is verplicht.");
        }

        string code;
        if (!string.IsNullOrWhiteSpace(dto.CustomCode))
        {
            code = dto.CustomCode.Trim().ToLower();
            var exists = await _db.ShortenedUrls.AnyAsync(u => u.Code.ToLower() == code);
            if (exists)
            {
                return BadRequest($"De code '{code}' is al in gebruik.");
            }
        }
        else
        {
            // Genereer een random unieke code van 6 tekens
            do
            {
                code = Guid.NewGuid().ToString("N")[..6];
            }
            while (await _db.ShortenedUrls.AnyAsync(u => u.Code.ToLower() == code));
        }

        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

        var shortened = new ShortenedUrl
        {
            Code = code,
            OriginalUrl = dto.OriginalUrl.Trim(),
            CreatedByUserId = userId
        };

        _db.ShortenedUrls.Add(shortened);
        await _db.SaveChangesAsync();

        return Ok(new ShortUrlDto(shortened.Id, shortened.Code, shortened.OriginalUrl, shortened.Clicks, shortened.CreatedAt));
    }

    // 4. Verwijderen van een short URL
    [Authorize]
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var link = await _db.ShortenedUrls.FindAsync(id);
        if (link == null) return NotFound();

        _db.ShortenedUrls.Remove(link);
        await _db.SaveChangesAsync();

        return NoContent();
    }
}