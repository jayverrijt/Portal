namespace Portal.Domain.Entities;

public class KanbanBoard : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }

    // Publieke status voor Google Docs-stijl delen zonder login
    public bool IsPublic { get; set; } = false;

    // Null = Standalone Inhouse Bord, anders gekoppeld aan een Project
    public Guid? ProjectId { get; set; }
    public Project? Project { get; set; }

    public ICollection<KanbanCard> Cards { get; set; } = new List<KanbanCard>();
    public ICollection<BoardLabel> Labels { get; set; } = new List<BoardLabel>();
}