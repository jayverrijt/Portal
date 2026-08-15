namespace Portal.Domain.Entities;

public class Reminder : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime DueDate { get; set; }
    public bool IsCompleted { get; set; }

    // Optionele koppeling met Project (Nullable Foreign Key)
    public Guid? ProjectId { get; set; }
    public Project? Project { get; set; }
}