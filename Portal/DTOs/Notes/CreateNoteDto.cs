using System.ComponentModel.DataAnnotations;

namespace Portal.DTOs.Notes;

public class CreateNoteDto
{
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public string Content { get; set; } = string.Empty;

    // Optioneel: Vul dit in om direct aan een project te koppelen, of laat null voor een losse notitie
    public Guid? ProjectId { get; set; }
}