using Portal.Domain.Entities;

namespace Portal.Domain.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IProjectRepository Projects { get; }
    INoteRepository Notes { get; }
    IRepository<Reminder> Reminders { get; }
    IRepository<ScheduledTask> ScheduledTasks { get; }
    IRepository<KanbanCard> KanbanCards { get; }
    IRepository<BoardLabel> BoardLabels { get; }
    IRepository<KanbanBoard> KanbanBoards { get; }

    Task<int> CompleteAsync();
}