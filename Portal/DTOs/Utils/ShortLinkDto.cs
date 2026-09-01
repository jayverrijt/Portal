namespace Portal.DTOs.Utils;

public class ShortLinkDto
{
    public Guid Id { get; set; }
    public string OriginalUrl { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string ShortUrl { get; set; } = string.Empty;
    public int Clicks { get; set; }
    public DateTime CreatedAt { get; set; }
}