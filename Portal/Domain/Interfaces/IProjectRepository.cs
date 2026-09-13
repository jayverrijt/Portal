using Portal.Domain.Entities;

namespace Portal.Domain.Interfaces;

public interface IProjectRepository : IRepository<Project>
{
    Task<IEnumerable<Project>> GetProjectsForUserAsync(string userId);
    Task<Project?> GetProjectWithDetailsAsync(Guid id);
}