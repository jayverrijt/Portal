using Portal.DTOs.Notes;
using Portal.DTOs.Reminders;

namespace Portal.DTOs.Projects;

public class ProjectDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? RepositoryUrl { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    public List<NoteDto> Notes { get; set; } = new();
    public List<ReminderDto> Reminders { get; set; } = new();
}