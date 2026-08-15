using System.ComponentModel.DataAnnotations;

namespace Portal.DTOs.Notes;

public class UpdateNoteDto
{
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public string Content { get; set; } = string.Empty;

    public Guid? ProjectId { get; set; }
}