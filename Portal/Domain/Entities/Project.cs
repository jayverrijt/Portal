namespace Portal.Domain.Entities;

public class Project : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? RepositoryUrl { get; set; }

    // Relaties
    public ICollection<Note> Notes { get; set; } = new List<Note>();
    public ICollection<Reminder> Reminders { get; set; } = new List<Reminder>();
}