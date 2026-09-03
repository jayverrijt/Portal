namespace Portal.DTOs.Shortener;

public record CreateShortUrlDto(string OriginalUrl, string? CustomCode);
public record ShortUrlDto(Guid Id, string Code, string OriginalUrl, int Clicks, DateTime CreatedAt);