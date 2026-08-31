using Portal.Domain.Entities;
using Portal.Domain.Interfaces;

namespace Portal.Data.Repositories;

public class UnitOfWork : IUnitOfWork
{
    private readonly PortalDbContext _context;

    public IRepository<Project> Projects { get; }
    public IRepository<Note> Notes { get; }
    public IRepository<Reminder> Reminders { get; }
    public IRepository<ScheduledTask> ScheduledTasks { get; }
    public IRepository<KanbanCard> KanbanCards => _kanbanCards ??= new Repository<KanbanCard>(_context);
    public IRepository<BoardLabel> BoardLabels => _boardLabels ??= new Repository<BoardLabel>(_context);

    private IRepository<KanbanCard>? _kanbanCards;
    private IRepository<BoardLabel>? _boardLabels;
    public UnitOfWork(PortalDbContext context)
    {
        _context = context;
        Projects = new Repository<Project>(_context);
        Notes = new Repository<Note>(_context);
        Reminders = new Repository<Reminder>(_context);
        ScheduledTasks = new Repository<ScheduledTask>(_context);
    }

    public IRepository<KanbanBoard> KanbanBoards => _kanbanBoards ??= new Repository<KanbanBoard>(_context);
    private IRepository<KanbanBoard>? _kanbanBoards;

    public async Task<int> CompleteAsync()
    {
        return await _context.SaveChangesAsync();
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}