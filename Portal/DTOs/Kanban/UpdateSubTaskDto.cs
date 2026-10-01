using Portal.Domain.Enums;

namespace Portal.DTOs.Kanban;

public class UpdateSubTaskDto
{
    public string Title { get; set; } = string.Empty;
    public SubTaskStatus Status { get; set; }
}