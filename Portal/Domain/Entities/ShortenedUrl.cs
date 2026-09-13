namespace Portal.Domain.Entities;

public class ShortenedUrl : BaseEntity
{
    public string Code { get; set; } = string.Empty;
    public string OriginalUrl { get; set; } = string.Empty;
    public int Clicks { get; set; } = 0;
    public string? CreatedByUserId { get; set; }
}