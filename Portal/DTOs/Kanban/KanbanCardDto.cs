using Portal.Domain.Enums;

namespace Portal.DTOs.Kanban;

public class KanbanCardDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public KanbanColumnStatus Status { get; set; }
    public int? SprintNumber { get; set; }
    public Guid BoardId { get; set; }
    public DateTime? DueDate { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public List<BoardLabelDto> Labels { get; set; } = new();
}