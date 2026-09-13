using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.JSInterop;
using Portal.WebApp.Client.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

var currentUri = new Uri(builder.HostEnvironment.BaseAddress);
string apiBaseUrl;

if (currentUri.Host == "localhost" || currentUri.Host == "127.0.0.1")
{
    apiBaseUrl = "http://localhost:5190/";
}
else if (currentUri.Host.EndsWith("jayverrijt.nl", StringComparison.OrdinalIgnoreCase))
{
    apiBaseUrl = "https://portalapi.jayverrijt.nl/";
}
else
{
    apiBaseUrl = $"{currentUri.Scheme}://{currentUri.Host}:5190/";
}

// DelegatingHandler registreren
builder.Services.AddScoped<AuthHeaderHandler>();

// HttpClient registreren met AuthHeaderHandler
builder.Services.AddScoped(sp =>
{
    var handler = sp.GetRequiredService<AuthHeaderHandler>();
    handler.InnerHandler = new HttpClientHandler();

    return new HttpClient(handler)
    {
        BaseAddress = new Uri(apiBaseUrl)
    };
});

// Authenticatie configuratie
builder.Services.AddAuthorizationCore();
builder.Services.AddCascadingAuthenticationState();

builder.Services.AddScoped<CustomAuthStateProvider>(sp => 
    new CustomAuthStateProvider(sp.GetService<IJSRuntime>(), sp.GetRequiredService<HttpClient>()));
builder.Services.AddScoped<AuthenticationStateProvider>(sp => sp.GetRequiredService<CustomAuthStateProvider>());

await builder.Build().RunAsync();
