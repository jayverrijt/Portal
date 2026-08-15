using System.Security.Claims;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.JSInterop;

namespace Portal.WebApp.Client.Services;

public class CustomAuthStateProvider : AuthenticationStateProvider
{
    private readonly IJSRuntime _jsRuntime;
    private readonly AuthenticationState _anonymous;

    public CustomAuthStateProvider(IJSRuntime jsRuntime)
    {
        _jsRuntime = jsRuntime;
        _anonymous = new AuthenticationState(new ClaimsPrincipal(new ClaimsIdentity()));
    }

    public override async Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        try
        {
            var token = await _jsRuntime.InvokeAsync<string>("sessionStorage.getItem", "authToken");
            if (string.IsNullOrWhiteSpace(token))
            {
                return _anonymous;
            }

            var claims = JwtParser.ParseClaimsFromJwt(token).ToList();

            // Controleer verloopdatum (exp claim)
            var expClaim = claims.FirstOrDefault(c => c.Type == "exp");
            if (expClaim != null && long.TryParse(expClaim.Value, out var expSeconds))
            {
                var expDate = DateTimeOffset.FromUnixTimeSeconds(expSeconds);
                if (expDate <= DateTimeOffset.UtcNow)
                {
                    await _jsRuntime.InvokeVoidAsync("sessionStorage.removeItem", "authToken");
                    return _anonymous;
                }
            }

            var identity = new ClaimsIdentity(claims, "jwt");
            var user = new ClaimsPrincipal(identity);

            return new AuthenticationState(user);
        }
        catch
        {
            return _anonymous;
        }
    }

    public async Task MarkUserAsAuthenticated(string token)
    {
        try
        {
            await _jsRuntime.InvokeVoidAsync("sessionStorage.setItem", "authToken", token);
            var claims = JwtParser.ParseClaimsFromJwt(token);
            var authenticatedUser = new ClaimsPrincipal(new ClaimsIdentity(claims, "jwt"));
            NotifyAuthenticationStateChanged(Task.FromResult(new AuthenticationState(authenticatedUser)));
        }
        catch
        {
            // Negeer
        }
    }

    public async Task MarkUserAsLoggedOut()
    {
        try
        {
            await _jsRuntime.InvokeVoidAsync("sessionStorage.removeItem", "authToken");
            NotifyAuthenticationStateChanged(Task.FromResult(_anonymous));
        }
        catch
        {
            // Negeer
        }
    }
}