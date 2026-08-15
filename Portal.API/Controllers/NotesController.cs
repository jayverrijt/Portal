using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;
using Portal.DTOs.Notes;

namespace Portal.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class NotesController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;

    public NotesController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<NoteDto>>> GetNotes([FromQuery] Guid? projectId)
    {
        // Als projectId is meegegeven filteren we daarop, anders halen we alle notities op
        var notes = projectId.HasValue
            ? await _unitOfWork.Notes.FindAsync(n => n.ProjectId == projectId.Value)
            : await _unitOfWork.Notes.GetAllAsync();

        var dtos = notes.Select(n => new NoteDto
        {
            Id = n.Id,
            Title = n.Title,
            Content = n.Content,
            ProjectId = n.ProjectId,
            CreatedAt = n.CreatedAt
        });

        return Ok(dtos);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<NoteDto>> GetNote(Guid id)
    {
        var note = await _unitOfWork.Notes.GetByIdAsync(id);
        if (note == null) return NotFound("Notitie niet gevonden.");

        return Ok(new NoteDto
        {
            Id = note.Id,
            Title = note.Title,
            Content = note.Content,
            ProjectId = note.ProjectId,
            CreatedAt = note.CreatedAt
        });
    }

    [HttpPost]
    public async Task<ActionResult<NoteDto>> CreateNote(CreateNoteDto dto)
    {
        if (dto.ProjectId.HasValue)
        {
            var projectExists = await _unitOfWork.Projects.GetByIdAsync(dto.ProjectId.Value);
            if (projectExists == null) return BadRequest("Opgegeven project bestaat niet.");
        }

        var note = new Note
        {
            Title = dto.Title,
            Content = dto.Content,
            ProjectId = dto.ProjectId
        };

        await _unitOfWork.Notes.AddAsync(note);
        await _unitOfWork.CompleteAsync();

        return CreatedAtAction(nameof(GetNote), new { id = note.Id }, new NoteDto
        {
            Id = note.Id,
            Title = note.Title,
            Content = note.Content,
            ProjectId = note.ProjectId,
            CreatedAt = note.CreatedAt
        });
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<NoteDto>> UpdateNote(Guid id, UpdateNoteDto dto)
    {
        var note = await _unitOfWork.Notes.GetByIdAsync(id);
        if (note == null) return NotFound("Notitie niet gevonden.");

        if (dto.ProjectId.HasValue)
        {
            var projectExists = await _unitOfWork.Projects.GetByIdAsync(dto.ProjectId.Value);
            if (projectExists == null) return BadRequest("Opgegeven project bestaat niet.");
        }

        note.Title = dto.Title;
        note.Content = dto.Content;
        note.ProjectId = dto.ProjectId;

        _unitOfWork.Notes.Update(note);
        await _unitOfWork.CompleteAsync();

        return Ok(new NoteDto
        {
            Id = note.Id,
            Title = note.Title,
            Content = note.Content,
            ProjectId = note.ProjectId,
            CreatedAt = note.CreatedAt
        });
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteNote(Guid id)
    {
        var note = await _unitOfWork.Notes.GetByIdAsync(id);
        if (note == null) return NotFound("Notitie niet gevonden.");

        _unitOfWork.Notes.Delete(note);
        await _unitOfWork.CompleteAsync();

        return NoContent();
    }
}