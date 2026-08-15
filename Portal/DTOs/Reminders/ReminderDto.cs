namespace Portal.DTOs.Reminders;

public class ReminderDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime DueDate { get; set; }
    public bool IsCompleted { get; set; }
    public Guid? ProjectId { get; set; }
    public DateTime CreatedAt { get; set; }
}