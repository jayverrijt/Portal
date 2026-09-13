using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Portal.Domain.Entities;

namespace Portal.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[EnableCors("AllowAll")]
[AllowAnonymous]
public class AuthController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AuthController> _logger;

    public AuthController(
        UserManager<ApplicationUser> userManager,
        IConfiguration configuration,
        ILogger<AuthController> logger)
    {
        _userManager = userManager;
        _configuration = configuration;
        _logger = logger;
    }

    public class LoginRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public class RegisterRequest
    {
        public string Email { get; set; } = string.Empty;
        public string? UserName { get; set; }
        public string Password { get; set; } = string.Empty;
    }

    public class AuthResponse
    {
        public string Token { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest("E-mailadres en wachtwoord zijn verplicht.");

            var user = await _userManager.FindByEmailAsync(request.Email.Trim());
            if (user == null)
            {
                _logger.LogWarning("Login mislukt: Gebruiker {Email} niet gevonden.", request.Email);
                return Unauthorized("Ongeldig e-mailadres of wachtwoord.");
            }

            var isValid = await _userManager.CheckPasswordAsync(user, request.Password);
            if (!isValid)
            {
                _logger.LogWarning("Login mislukt: Ongeldig wachtwoord voor {Email}.", request.Email);
                return Unauthorized("Ongeldig e-mailadres of wachtwoord.");
            }

            var tokenString = GenerateJwtToken(user);

            _logger.LogInformation("Gebruiker {Email} succesvol ingelogd.", user.Email);

            return Ok(new AuthResponse
            {
                Token = tokenString,
                Email = user.Email ?? ""
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fout bij inloggen voor {Email}: {Message}", request.Email, ex.Message);
            return StatusCode(500, $"Serverfout: {ex.Message}");
        }
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest(new { message = "E-mailadres en wachtwoord zijn verplicht." });

            var email = request.Email.Trim();
            var existingUser = await _userManager.FindByEmailAsync(email);
            if (existingUser != null)
            {
                _logger.LogWarning("Registratie mislukt: E-mailadres {Email} is al in gebruik.", email);
                return Conflict(new { message = "Dit e-mailadres is al in gebruik." });
            }

            var username = !string.IsNullOrWhiteSpace(request.UserName) ? request.UserName.Trim() : email;
            var user = new ApplicationUser
            {
                UserName = username,
                Email = email
            };

            var result = await _userManager.CreateAsync(user, request.Password);
            if (!result.Succeeded)
            {
                var errors = result.Errors.Select(e => e.Description);
                _logger.LogWarning("Registratie mislukt voor {Email}: {Errors}", email, string.Join(", ", errors));
                return BadRequest(new { message = "Registratie mislukt.", errors });
            }

            _logger.LogInformation("Nieuw account succesvol aangemaakt voor {Email}.", email);

            // Genereer direct een token zodat de gebruiker direct ingelogd kan worden
            var tokenString = GenerateJwtToken(user);

            return Ok(new AuthResponse
            {
                Token = tokenString,
                Email = user.Email ?? ""
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fout bij registreren voor {Email}: {Message}", request.Email, ex.Message);
            return StatusCode(500, new { message = $"Serverfout: {ex.Message}" });
        }
    }

    private string GenerateJwtToken(ApplicationUser user)
    {
        var rawKey = _configuration["Jwt:Key"] ?? "SuperSecretPortalJwtSigningKey2026!WithSufficientLength";
        if (rawKey.Length < 32)
        {
            rawKey = rawKey.PadRight(32, 'X');
        }

        var jwtIssuer = _configuration["Jwt:Issuer"] ?? "https://api.portal.jayverrijt.nl";
        var jwtAudience = _configuration["Jwt:Audience"] ?? "https://portal.jayverrijt.nl";

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Name, user.UserName ?? user.Email ?? ""),
            new(ClaimTypes.Email, user.Email ?? "")
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(rawKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: jwtIssuer,
            audience: jwtAudience,
            claims: claims,
            expires: DateTime.UtcNow.AddDays(14),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}