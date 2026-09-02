using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Portal.Data;
using Portal.Data.Repositories;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;

var builder = WebApplication.CreateBuilder(args);

// 1. CORS CONFIGURATIE
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// 2. DATABASE CONFIGURATIE
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<PortalDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

// 3. REPOSITORY & UNIT OF WORK REGISTRATIE
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

// 4. ASP.NET CORE IDENTITY
builder.Services.AddHttpContextAccessor();

builder.Services.AddIdentityCore<ApplicationUser>(options =>
{
    options.Password.RequireDigit = false;
    options.Password.RequireLowercase = false;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase = false;
    options.Password.RequiredLength = 6;
})
.AddRoles<IdentityRole>()
.AddEntityFrameworkStores<PortalDbContext>()
.AddSignInManager()
.AddDefaultTokenProviders();

// 5. JWT AUTHENTICATION CONFIGURATIE
var jwtKey = builder.Configuration["Jwt:Key"] ?? "SuperSecretPortalJwtSigningKey2026!WithSufficientLength";
if (jwtKey.Length < 32)
{
    jwtKey = jwtKey.PadRight(32, 'X');
}

var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "https://api.portal.jayverrijt.nl";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "https://portal.jayverrijt.nl";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
        ValidateIssuer = true,
        ValidIssuer = jwtIssuer,
        ValidateAudience = true,
        ValidAudience = jwtAudience,
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

// 6. CONTROLLERS & SWAGGER
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Portal API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header met Bearer schema. Bv: 'Bearer {token}'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// 7. DATABASE MIGRATIE & SEEDING
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var logger = services.GetRequiredService<ILogger<Program>>();

    int maxRetries = 10;
    for (int retry = 1; retry <= maxRetries; retry++)
    {
        try
        {
            logger.LogInformation("Poging {Retry}/{MaxRetries} om database te migreren...", retry, maxRetries);
            var db = services.GetRequiredService<PortalDbContext>();
            db.Database.Migrate();
            logger.LogInformation("Database migraties succesvol toegepast!");

            var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();
            var defaultEmail = "jay@famverrijt.nl";
            var existingUser = userManager.FindByEmailAsync(defaultEmail).GetAwaiter().GetResult();

            if (existingUser == null)
            {
                var newUser = new ApplicationUser
                {
                    UserName = defaultEmail,
                    Email = defaultEmail,
                    EmailConfirmed = true
                };

                var createResult = userManager.CreateAsync(newUser, "Welkom123!").GetAwaiter().GetResult();
                if (createResult.Succeeded)
                {
                    logger.LogInformation("Default gebruiker '{Email}' succesvol aangemaakt.", defaultEmail);
                }
                else
                {
                    logger.LogWarning("Kon default gebruiker niet aanmaken: {Errors}", 
                        string.Join(", ", createResult.Errors.Select(e => e.Description)));
                }
            }
            break;
        }
        catch (Exception ex)
        {
            logger.LogWarning("Database nog niet gereed (Poging {Retry}): {Message}", retry, ex.Message);
            if (retry == maxRetries)
            {
                logger.LogError(ex, "Database migratie mislukt na {MaxRetries} pogingen.", maxRetries);
            }
            else
            {
                Thread.Sleep(3000);
            }
        }
    }
}

// 8. HTTP PIPELINE
if (app.Environment.IsDevelopment() || app.Environment.IsProduction())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
