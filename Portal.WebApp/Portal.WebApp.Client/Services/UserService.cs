using System.Net.Http.Json;
using Microsoft.AspNetCore.Components.Forms;

namespace Portal.WebApp.Client.Services;

public class UserProfileDto
{
    public string? Email { get; set; }
    public string? FullName { get; set; }
    public string? ProfilePictureUrl { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class UserService
{
    private readonly HttpClient _http;

    public UserService(HttpClient http)
    {
        _http = http;
    }

    public async Task<UserProfileDto?> GetProfileAsync()
    {
        try
        {
            return await _http.GetFromJsonAsync<UserProfileDto>("api/UserSettings");
        }
        catch
        {
            return null;
        }
    }

    public async Task<bool> UpdateProfileAsync(string? fullName, string? profilePictureUrl)
    {
        try
        {
            var response = await _http.PutAsJsonAsync("api/UserSettings", new
            {
                FullName = fullName,
                ProfilePictureUrl = profilePictureUrl
            });

            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }

    public async Task<string?> UploadProfilePictureAsync(IBrowserFile file)
    {
        try
        {
            using var content = new MultipartFormDataContent();
            var fileStream = file.OpenReadStream(maxAllowedSize: 5 * 1024 * 1024); // Max 5MB
            using var streamContent = new StreamContent(fileStream);
            streamContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(file.ContentType);

            content.Add(streamContent, "file", file.Name);

            var response = await _http.PostAsync("api/UserSettings/upload-picture", content);
            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadFromJsonAsync<Dictionary<string, string>>();
                return result != null && result.TryGetValue("url", out var url) ? url : null;
            }
        }
        catch
        {
            // Foutafhandeling
        }
        return null;
    }
}