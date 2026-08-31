using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;
using Portal.DTOs.Kanban;

namespace Portal.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class BoardLabelsController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;

    public BoardLabelsController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<BoardLabelDto>>> GetLabels([FromQuery] Guid boardId)
    {
        var labels = await _unitOfWork.BoardLabels.FindAsync(l => l.BoardId == boardId);

        var dtos = labels.Select(l => new BoardLabelDto
        {
            Id = l.Id,
            Name = l.Name,
            ColorHex = l.ColorHex,
            BoardId = l.BoardId
        });

        return Ok(dtos);
    }

    [HttpPost]
    public async Task<ActionResult<BoardLabelDto>> CreateLabel([FromBody] CreateBoardLabelDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Name))
            return BadRequest("Labelnaam is verplicht.");

        var board = await _unitOfWork.KanbanBoards.GetByIdAsync(dto.BoardId);
        if (board == null) return NotFound("Bord niet gevonden.");

        var label = new BoardLabel
        {
            Name = dto.Name.Trim(),
            ColorHex = string.IsNullOrWhiteSpace(dto.ColorHex) ? "#3B82F6" : dto.ColorHex,
            BoardId = dto.BoardId
        };

        await _unitOfWork.BoardLabels.AddAsync(label);
        await _unitOfWork.CompleteAsync();

        return Ok(new BoardLabelDto
        {
            Id = label.Id,
            Name = label.Name,
            ColorHex = label.ColorHex,
            BoardId = label.BoardId
        });
    }
}