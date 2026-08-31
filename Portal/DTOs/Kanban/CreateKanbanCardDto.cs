using Portal.Domain.Enums;

namespace Portal.DTOs.Kanban;

public class CreateKanbanCardDto
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public KanbanColumnStatus Status { get; set; } = KanbanColumnStatus.Backlog;
    public int? SprintNumber { get; set; }
    public Guid BoardId { get; set; }
    public DateTime? DueDate { get; set; }
    public List<Guid> LabelIds { get; set; } = new();
}