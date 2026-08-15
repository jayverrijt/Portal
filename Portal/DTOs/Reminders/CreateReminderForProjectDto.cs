namespace Portal.DTOs.Reminders;

public class CreateReminderForProjectDto
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime DueDate { get; set; }
}