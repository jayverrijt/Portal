using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.JSInterop;

namespace Portal.WebApp.Client.Services;

public class CustomAuthStateProvider : AuthenticationStateProvider
{
    private readonly IJSRuntime _js;
    private readonly AuthenticationState _anonymous = new(new ClaimsPrincipal(new ClaimsIdentity()));
    private const string TokenKey = "authToken";

    public CustomAuthStateProvider(IJSRuntime js)
    {
        _js = js;
    }

    public override async Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        try
        {
            var token = await _js.InvokeAsync<string?>("localStorage.getItem", TokenKey);

            if (string.IsNullOrWhiteSpace(token))
            {
                return _anonymous;
            }

            var claims = ParseClaimsFromJwt(token).ToList();

            var expClaim = claims.FirstOrDefault(c => c.Type == "exp");
            if (expClaim != null && long.TryParse(expClaim.Value, out var expSeconds))
            {
                var expDate = DateTimeOffset.FromUnixTimeSeconds(expSeconds).UtcDateTime;
                if (expDate < DateTime.UtcNow)
                {
                    await _js.InvokeVoidAsync("localStorage.removeItem", TokenKey);
                    return _anonymous;
                }
            }

            var identity = new ClaimsIdentity(claims, "jwt", ClaimTypes.Name, ClaimTypes.Role);
            return new AuthenticationState(new ClaimsPrincipal(identity));
        }
        catch
        {
            return _anonymous;
        }
    }

    public async Task SetTokenAsync(string? token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            await _js.InvokeVoidAsync("localStorage.removeItem", TokenKey);
            NotifyAuthenticationStateChanged(Task.FromResult(_anonymous));
        }
        else
        {
            await _js.InvokeVoidAsync("localStorage.setItem", TokenKey, token);
            var claims = ParseClaimsFromJwt(token).ToList();
            var identity = new ClaimsIdentity(claims, "jwt", ClaimTypes.Name, ClaimTypes.Role);
            var principal = new ClaimsPrincipal(identity);
            NotifyAuthenticationStateChanged(Task.FromResult(new AuthenticationState(principal)));
        }
    }

    private static IEnumerable<Claim> ParseClaimsFromJwt(string jwt)
    {
        var claims = new List<Claim>();
        var parts = jwt.Split('.');
        if (parts.Length < 2) return claims;

        var payload = parts[1];
        var jsonBytes = ParseBase64WithoutPadding(payload);
        var keyValuePairs = JsonSerializer.Deserialize<Dictionary<string, object>>(jsonBytes);

        if (keyValuePairs == null) return claims;

        foreach (var kvp in keyValuePairs)
        {
            var valueStr = kvp.Value?.ToString() ?? string.Empty;

            if (kvp.Key == "nameid" || kvp.Key == "sub")
            {
                claims.Add(new Claim(ClaimTypes.NameIdentifier, valueStr));
            }
            else if (kvp.Key == "email" || kvp.Key == "unique_name")
            {
                claims.Add(new Claim(ClaimTypes.Name, valueStr));
                claims.Add(new Claim(ClaimTypes.Email, valueStr));
            }

            claims.Add(new Claim(kvp.Key, valueStr));
        }

        return claims;
    }

    private static byte[] ParseBase64WithoutPadding(string base64)
    {
        switch (base64.Length % 4)
        {
            case 2: base64 += "=="; break;
            case 3: base64 += "="; break;
        }
        return Convert.FromBase64String(base64);
    }
}