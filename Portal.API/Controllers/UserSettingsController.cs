using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Portal.Domain.Entities;

namespace Portal.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[EnableCors("AllowAll")]
[Authorize]
public class UserSettingsController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly ILogger<UserSettingsController> _logger;

    public UserSettingsController(
        UserManager<ApplicationUser> userManager,
        ILogger<UserSettingsController> logger)
    {
        _userManager = userManager;
        _logger = logger;
    }

    public class UpdateUserSettingsDto
    {
        public string? FullName { get; set; }
        public string? ProfilePictureUrl { get; set; }
    }

    [HttpGet]
    public async Task<IActionResult> GetSettings()
    {
        try
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return NotFound(new { message = "Gebruiker niet gevonden." });
            }

            return Ok(new
            {
                email = user.Email,
                fullName = user.FullName ?? string.Empty,
                profilePictureUrl = user.ProfilePictureUrl ?? string.Empty,
                createdAt = user.CreatedAt
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fout bij ophalen van gebruikersinstellingen.");
            return StatusCode(500, new { message = $"Serverfout: {ex.Message}" });
        }
    }

    [HttpPut]
    public async Task<IActionResult> UpdateSettings([FromBody] UpdateUserSettingsDto dto)
    {
        try
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return NotFound(new { message = "Gebruiker niet gevonden." });
            }

            user.FullName = dto.FullName?.Trim();
            user.ProfilePictureUrl = dto.ProfilePictureUrl?.Trim();

            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded)
            {
                var errors = result.Errors.Select(e => e.Description);
                return BadRequest(new { message = "Kon instellingen niet bijwerken.", errors });
            }

            _logger.LogInformation("Instellingen bijgewerkt voor gebruiker {Email}.", user.Email);

            return Ok(new { message = "Instellingen succesvol bijgewerkt" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fout bij bijwerken van gebruikersinstellingen.");
            return StatusCode(500, new { message = $"Serverfout: {ex.Message}" });
        }
    }

    [HttpPost("upload-picture")]
    public async Task<IActionResult> UploadProfilePicture(IFormFile file)
    {
        try
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return NotFound(new { message = "Gebruiker niet gevonden." });

            if (file == null || file.Length == 0)
                return BadRequest(new { message = "Geen geldig bestand geselecteerd." });

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "profiles");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            var fileName = $"{user.Id}_{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var filePath = Path.Combine(uploadsFolder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Absolute URL genereren zodat de frontend de foto direct kan inladen vanaf de API
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            user.ProfilePictureUrl = $"{baseUrl}/uploads/profiles/{fileName}";

            await _userManager.UpdateAsync(user);

            return Ok(new { url = user.ProfilePictureUrl });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fout bij uploaden profielfoto.");
            return StatusCode(500, new { message = $"Serverfout: {ex.Message}" });
        }
    }
}