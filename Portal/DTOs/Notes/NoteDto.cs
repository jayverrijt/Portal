namespace Portal.DTOs.Notes;

public class NoteDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public Guid? ProjectId { get; set; }
    public DateTime CreatedAt { get; set; }
}