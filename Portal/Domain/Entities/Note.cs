namespace Portal.Domain.Entities;

public class Note : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;

    // Optionele koppeling met Project (Nullable Foreign Key)
    public Guid? ProjectId { get; set; }
    public Project? Project { get; set; }
}