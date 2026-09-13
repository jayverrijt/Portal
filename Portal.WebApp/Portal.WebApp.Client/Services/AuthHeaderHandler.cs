using System.Net.Http.Headers;
using Microsoft.JSInterop;

namespace Portal.WebApp.Client.Services;

public class AuthHeaderHandler : DelegatingHandler
{
    private readonly IJSRuntime _js;

    public AuthHeaderHandler(IJSRuntime js)
    {
        _js = js;
    }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        try
        {
            var token = await _js.InvokeAsync<string?>("localStorage.getItem", "authToken");
            if (!string.IsNullOrWhiteSpace(token))
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            }
        }
        catch
        {
            // Negeren tijdens eventuele prerender of initialisatie
        }

        return await base.SendAsync(request, cancellationToken);
    }
}
