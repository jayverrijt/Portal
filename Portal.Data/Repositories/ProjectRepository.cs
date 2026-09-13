using Microsoft.EntityFrameworkCore;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;

namespace Portal.Data.Repositories;

public class ProjectRepository : Repository<Project>, IProjectRepository
{
    public ProjectRepository(PortalDbContext context) : base(context)
    {
    }

    public async Task<IEnumerable<Project>> GetProjectsForUserAsync(string userId)
    {
        return await _dbSet
            .Include(p => p.SharedWithUsers)
            .Where(p => p.OwnerId == userId || p.SharedWithUsers.Any(u => u.Id == userId))
            .ToListAsync();
    }

    public async Task<Project?> GetProjectWithDetailsAsync(Guid id)
    {
        return await _dbSet
            .Include(p => p.SharedWithUsers)
            .FirstOrDefaultAsync(p => p.Id == id);
    }
}