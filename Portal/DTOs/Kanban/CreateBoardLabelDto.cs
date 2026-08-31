namespace Portal.DTOs.Kanban;

public class CreateBoardLabelDto
{
    public string Name { get; set; } = string.Empty;
    public string ColorHex { get; set; } = "#3B82F6";
    public Guid BoardId { get; set; }
}