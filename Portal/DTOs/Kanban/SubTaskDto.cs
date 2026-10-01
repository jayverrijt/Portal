using Portal.Domain.Enums;

namespace Portal.DTOs.Kanban;

public class SubTaskDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public SubTaskStatus Status { get; set; }
    public Guid CardId { get; set; }
}