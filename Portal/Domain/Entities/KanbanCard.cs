using Portal.Domain.Enums;

namespace Portal.Domain.Entities;

public class KanbanCard : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public KanbanColumnStatus Status { get; set; } = KanbanColumnStatus.Backlog;

    // Sprint indeling (1, 2, 3... null = geen sprint)
    public int? SprintNumber { get; set; }

    // Gekoppeld aan het specifieke KanbanBoard
    public Guid BoardId { get; set; }
    public KanbanBoard? Board { get; set; }

    // Labels gekoppeld aan deze kaart
    public ICollection<BoardLabel> Labels { get; set; } = new List<BoardLabel>();

    public DateTime? DueDate { get; set; }
    public DateTime? UpdatedAt { get; set; }
}