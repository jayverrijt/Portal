using Portal.Domain.Entities;

namespace Portal.Domain.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IRepository<Project> Projects { get; }
    IRepository<Note> Notes { get; }
    IRepository<Reminder> Reminders { get; }
    IRepository<ScheduledTask> ScheduledTasks { get; }
    IRepository<KanbanCard> KanbanCards { get; }
    IRepository<BoardLabel> BoardLabels { get; }
    IRepository<KanbanBoard> KanbanBoards { get; }

    Task<int> CompleteAsync();
}