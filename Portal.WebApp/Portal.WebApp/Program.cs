using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Components.Authorization;
using Portal.WebApp.Client.Services;
using Portal.WebApp.Components;

var builder = WebApplication.CreateBuilder(args);

// 1. Razor Components voor Interactive Server & WebAssembly
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents()
    .AddInteractiveWebAssemblyComponents();

// 2. Authenticatie & Autorisatie schema's
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/login";
    });

builder.Services.AddAuthorization();
builder.Services.AddCascadingAuthenticationState();

// 3. HttpClient voor SSR container-to-container calls
var apiInternalUrl = builder.Configuration["ApiUrl"] ?? "http://portal-api:8080/";
builder.Services.AddScoped(sp => new HttpClient 
{ 
    BaseAddress = new Uri(apiInternalUrl) 
});

// 4. Registreer CustomAuthStateProvider op de server voor SSR
builder.Services.AddScoped<ServerAuthStateProvider>();
builder.Services.AddScoped<CustomAuthStateProvider>(sp => sp.GetRequiredService<ServerAuthStateProvider>());
builder.Services.AddScoped<AuthenticationStateProvider>(sp => sp.GetRequiredService<ServerAuthStateProvider>());

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseWebAssemblyDebugging();
}
else
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseStaticFiles();
app.UseAntiforgery();

app.UseAuthentication();
app.UseAuthorization();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode()
    .AddInteractiveWebAssemblyRenderMode()
    .AddAdditionalAssemblies(typeof(Portal.WebApp.Client._Imports).Assembly);

app.Run();

// Server-side fallback implementatie van CustomAuthStateProvider
public class ServerAuthStateProvider : CustomAuthStateProvider
{
    public ServerAuthStateProvider(HttpClient httpClient) : base(null, httpClient)
    {
    }

    public override Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        return Task.FromResult(new AuthenticationState(new ClaimsPrincipal(new ClaimsIdentity())));
    }
}
