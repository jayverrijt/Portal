using System.ComponentModel.DataAnnotations;

namespace Portal.DTOs.Projects;

public class CreateProjectDto
{
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    [MaxLength(500)]
    [Url]
    public string? RepositoryUrl { get; set; }
}