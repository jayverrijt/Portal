namespace Portal.DTOs.Utils;

public class CreateWeightLogDto
{
    public double WeightKg { get; set; }
    public DateTime Timestamp { get; set; }
    public string TimeSlot { get; set; } = "Ochtend";
}