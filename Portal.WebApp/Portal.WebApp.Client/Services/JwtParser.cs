using System.Security.Claims;
using System.Text.Json;

namespace Portal.WebApp.Client.Services;

public static class JwtParser
{
    public static List<Claim> ParseClaimsFromJwt(string jwt)
    {
        List<Claim> claims = new List<Claim>();
        var payload = jwt.Split('.')[1];
        var jsonBytes = ParseBase64WithoutPadding(payload);
        var keyValuePairs = JsonSerializer.Deserialize<Dictionary<string, object>>(jsonBytes);

        if (keyValuePairs != null)
        {
            if (keyValuePairs.TryGetValue(ClaimTypes.Role, out var roles) && roles != null)
            {
                var rolesString = roles.ToString();
                if (!string.IsNullOrEmpty(rolesString))
                {
                    if (rolesString.StartsWith("["))
                    {
                        var parsedRoles = JsonSerializer.Deserialize<string[]>(rolesString);
                        if (parsedRoles != null)
                        {
                            foreach (var parsedRole in parsedRoles)
                            {
                                claims.Add(new Claim(ClaimTypes.Role, parsedRole));
                            }
                        }
                    }
                    else
                    {
                        claims.Add(new Claim(ClaimTypes.Role, rolesString));
                    }
                }
                keyValuePairs.Remove(ClaimTypes.Role);
            }

            foreach (var kvp in keyValuePairs)
            {
                claims.Add(new Claim(kvp.Key, kvp.Value?.ToString() ?? string.Empty));
            }
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