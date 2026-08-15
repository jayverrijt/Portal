using System.ComponentModel.DataAnnotations;

namespace Portal.DTOs.Reminders;

public class UpdateReminderDto
{
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    [Required]
    public DateTime DueDate { get; set; }

    public bool IsCompleted { get; set; }

    public Guid? ProjectId { get; set; }
}