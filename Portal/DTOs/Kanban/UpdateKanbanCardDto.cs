using Portal.Domain.Enums;

namespace Portal.DTOs.Kanban;
public class UpdateKanbanCardDto
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public KanbanColumnStatus Status { get; set; }
    public int? SprintNumber { get; set; }
    public DateTime? DueDate { get; set; }
    public List<Guid> LabelIds { get; set; } = new();
}