namespace Portal.Domain.Entities;

public class Note : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;

    // Eigenaar (nullable om bestaande data te beschermen)
    public string? OwnerId { get; set; }
    public ApplicationUser? Owner { get; set; }

    // Optionele koppeling met Project
    public Guid? ProjectId { get; set; }
    public Project? Project { get; set; }

    // Direct delen van losse notities
    public ICollection<ApplicationUser> SharedWithUsers { get; set; } = new List<ApplicationUser>();
}