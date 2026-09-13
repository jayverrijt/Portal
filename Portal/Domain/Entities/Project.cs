namespace Portal.Domain.Entities;

public class Project : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? RepositoryUrl { get; set; }

    // Eigenaar (nullable om bestaande data te beschermen)
    public string? OwnerId { get; set; }
    public ApplicationUser? Owner { get; set; }

    // Veel-op-veel relatie voor delen
    public ICollection<ApplicationUser> SharedWithUsers { get; set; } = new List<ApplicationUser>();

    // Relaties
    public ICollection<Note> Notes { get; set; } = new List<Note>();
    public ICollection<Reminder> Reminders { get; set; } = new List<Reminder>();
}