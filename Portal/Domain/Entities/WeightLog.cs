namespace Portal.Domain.Entities;

public class WeightLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public double WeightKg { get; set; }
    public DateTime Timestamp { get; set; }
    public string TimeSlot { get; set; } = "Ochtend"; // Ochtend, Middag, Avond
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}