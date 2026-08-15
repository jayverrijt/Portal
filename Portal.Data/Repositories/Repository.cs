using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Portal.Domain.Entities;
using Portal.Domain.Interfaces;

namespace Portal.Data.Repositories;

public class Repository<T> : IRepository<T> where T : BaseEntity
{
    protected readonly PortalDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public Repository(PortalDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public async Task<T?> GetByIdAsync(Guid id)
    {
        return await _dbSet.FindAsync(id);
    }

    public async Task<IEnumerable<T>> GetAllAsync()
    {
        return await _dbSet.ToListAsync();
    }

    public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.Where(predicate).ToListAsync();
    }

    public async Task AddAsync(T entity)
    {
        await _dbSet.AddAsync(entity);
    }

    public void Update(T entity)
    {
        entity.UpdatedAt = DateTime.UtcNow;
        _dbSet.Update(entity);
    }

    public void Delete(T entity)
    {
        _dbSet.Remove(entity);
    }
}