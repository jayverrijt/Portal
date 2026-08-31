namespace Portal.DTOs.Kanban;

public class BoardLabelDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string ColorHex { get; set; } = string.Empty;
    public Guid BoardId { get; set; }
}