using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Components.Authorization;
using Portal.WebApp.Client.Services;
using Portal.WebApp.Components;

var builder = WebApplication.CreateBuilder(args);

// 1. Blazor Components
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents()
    .AddInteractiveWebAssemblyComponents();

// 2. HTTP Client & JWT Handler (voor SSR & API Calls)
builder.Services.AddTransient<JwtAuthorizationHandler>();
builder.Services.AddScoped(sp =>
{
    var handler = sp.GetRequiredService<JwtAuthorizationHandler>();
    handler.InnerHandler = new HttpClientHandler();
    return new HttpClient(handler)
    {
        BaseAddress = new Uri("http://localhost:5190/")
    };
});

// 3. Fallback Authenticatie met het juiste loginpad (/login)
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/login";
    });
builder.Services.AddAuthorization();

// 4. Blazor Auth State Provider
builder.Services.AddCascadingAuthenticationState();
builder.Services.AddScoped<AuthenticationStateProvider, CustomAuthStateProvider>();

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

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseAntiforgery();

app.UseAuthentication();
app.UseAuthorization();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode()
    .AddInteractiveWebAssemblyRenderMode()
    .AddAdditionalAssemblies(typeof(Portal.WebApp.Client._Imports).Assembly);

app.Run();