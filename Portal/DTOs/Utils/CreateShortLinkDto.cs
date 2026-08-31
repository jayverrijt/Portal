namespace Portal.DTOs.Utils;

public class CreateShortLinkDto
{
    public string OriginalUrl { get; set; } = string.Empty;
    public string? Slug { get; set; }
}