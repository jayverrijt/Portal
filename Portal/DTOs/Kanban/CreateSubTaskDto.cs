using Portal.Domain.Enums;

namespace Portal.DTOs.Kanban;

public class CreateSubTaskDto
{
    public string Title { get; set; } = string.Empty;
    public SubTaskStatus Status { get; set; } = SubTaskStatus.Todo;
}