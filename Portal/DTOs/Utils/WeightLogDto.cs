namespace Portal.DTOs.Utils;

public class WeightLogDto
{
    public Guid Id { get; set; }
    public double WeightKg { get; set; }
    public DateTime Timestamp { get; set; }
    public string TimeSlot { get; set; } = string.Empty;
}