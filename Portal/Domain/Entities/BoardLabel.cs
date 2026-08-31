namespace Portal.Domain.Entities;

public class BoardLabel : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string ColorHex { get; set; } = "#3B82F6";

    // Gekoppeld aan het specifieke KanbanBoard
    public Guid BoardId { get; set; }
    public KanbanBoard? Board { get; set; }

    public ICollection<KanbanCard> Cards { get; set; } = new List<KanbanCard>();
}