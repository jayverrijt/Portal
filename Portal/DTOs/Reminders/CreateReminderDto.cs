using System.ComponentModel.DataAnnotations;

namespace Portal.DTOs.Reminders;

public class CreateReminderDto
{
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    [Required]
    public DateTime DueDate { get; set; }

    // Optioneel: Vul dit in om direct aan een project te koppelen, of laat null voor een losse reminder
    public Guid? ProjectId { get; set; }
}