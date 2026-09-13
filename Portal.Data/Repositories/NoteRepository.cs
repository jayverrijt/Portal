using Microsoft.EntityFrameworkCore;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;

namespace Portal.Data.Repositories;

public class NoteRepository : Repository<Note>, INoteRepository
{
    public NoteRepository(PortalDbContext context) : base(context)
    {
    }

    public async Task<IEnumerable<Note>> GetNotesForUserAsync(string userId, Guid? projectId = null)
    {
        var query = _dbSet
            .Include(n => n.SharedWithUsers)
            .Include(n => n.Project)
            .ThenInclude(p => p!.SharedWithUsers)
            .Where(n => 
                n.OwnerId == userId 
                || n.SharedWithUsers.Any(u => u.Id == userId)
                || (n.Project != null && (n.Project.OwnerId == userId || n.Project.SharedWithUsers.Any(u => u.Id == userId)))
            );

        if (projectId.HasValue)
        {
            query = query.Where(n => n.ProjectId == projectId.Value);
        }

        return await query.ToListAsync();
    }

    public async Task<Note?> GetNoteWithDetailsAsync(Guid id)
    {
        return await _dbSet
            .Include(n => n.SharedWithUsers)
            .Include(n => n.Project)
            .ThenInclude(p => p!.SharedWithUsers)
            .FirstOrDefaultAsync(n => n.Id == id);
    }
}