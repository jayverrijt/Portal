using Portal.Domain.Entities;

namespace Portal.Domain.Interfaces;

public interface INoteRepository : IRepository<Note>
{
    Task<IEnumerable<Note>> GetNotesForUserAsync(string userId, Guid? projectId = null);
    Task<Note?> GetNoteWithDetailsAsync(Guid id);
}