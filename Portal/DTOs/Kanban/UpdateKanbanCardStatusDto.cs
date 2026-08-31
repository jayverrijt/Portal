using Portal.Domain.Enums;

namespace Portal.DTOs.Kanban;

public class UpdateKanbanCardStatusDto
{
    public KanbanColumnStatus Status { get; set; }
}