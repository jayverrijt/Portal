using Portal.Domain.Enums;

namespace Portal.Domain.Entities;

public class KanbanCard : BaseEntity
{
    public string Title { get; set; } = string.Empty; // Use Case Naam
    public string? Description { get; set; }
    public KanbanColumnStatus Status { get; set; } = KanbanColumnStatus.Backlog;

    // Sprint indeling
    public int? SprintNumber { get; set; }

    // MoSCoW Prioritering
    public MoscowPriority? MoscowPriority { get; set; }

    // Gekoppeld aan KanbanBoard
    public Guid BoardId { get; set; }
    public KanbanBoard? Board { get; set; }

    // Labels & Subtasks
    public ICollection<BoardLabel> Labels { get; set; } = new List<BoardLabel>();
    public ICollection<SubTask> SubTasks { get; set; } = new List<SubTask>();

    public DateTime? DueDate { get; set; }
    public new DateTime? UpdatedAt { get; set; }
}