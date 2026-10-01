using Portal.Domain.Enums;

namespace Portal.Domain.Entities;

public class SubTask : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public SubTaskStatus Status { get; set; } = SubTaskStatus.Todo;

    public Guid CardId { get; set; }
    public KanbanCard Card { get; set; } = null!;
}