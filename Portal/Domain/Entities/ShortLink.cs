namespace Portal.Domain.Entities;

public class ShortLink
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public string OriginalUrl { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public int Clicks { get; set; } = 0;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}