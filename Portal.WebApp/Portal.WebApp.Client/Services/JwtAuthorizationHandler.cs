using System.Net.Http.Headers;
using Microsoft.JSInterop;

namespace Portal.WebApp.Client.Services;

public class JwtAuthorizationHandler : DelegatingHandler
{
    private readonly IJSRuntime _jsRuntime;

    public JwtAuthorizationHandler(IJSRuntime jsRuntime)
    {
        _jsRuntime = jsRuntime;
    }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        try
        {
            var token = await _jsRuntime.InvokeAsync<string>("sessionStorage.getItem", "authToken");
            if (!string.IsNullOrWhiteSpace(token))
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            }
        }
        catch (InvalidOperationException)
        {
            // JS interop niet beschikbaar tijdens server prerendering
        }
        catch (Exception)
        {
            // Fallback
        }

        return await base.SendAsync(request, cancellationToken);
    }
}