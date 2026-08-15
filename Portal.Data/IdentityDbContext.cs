using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Portal.Domain.Entities;

namespace Portal.Data;

public class PortalDbContext : IdentityDbContext<ApplicationUser>
{
    public PortalDbContext(DbContextOptions<PortalDbContext> options) : base(options)
    {
    }

    public DbSet<Project> Projects => Set<Project>();
    public DbSet<Note> Notes => Set<Note>();
    public DbSet<Reminder> Reminders => Set<Reminder>();
    public DbSet<ScheduledTask> ScheduledTasks => Set<ScheduledTask>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Project configuration
        modelBuilder.Entity<Project>(entity =>
        {
            entity.HasKey(p => p.Id);
            entity.Property(p => p.Title).IsRequired().HasMaxLength(200);
            entity.Property(p => p.Description).HasColumnType("text");
            entity.Property(p => p.RepositoryUrl).HasMaxLength(500);
        });

        // Note configuration
        modelBuilder.Entity<Note>(entity =>
        {
            entity.HasKey(n => n.Id);
            entity.Property(n => n.Title).IsRequired().HasMaxLength(200);
            entity.Property(n => n.Content).HasColumnType("longtext");

            entity.HasOne(n => n.Project)
                  .WithMany(p => p.Notes)
                  .HasForeignKey(n => n.ProjectId)
                  .OnDelete(DeleteBehavior.SetNull);
        });

        // Reminder configuration
        modelBuilder.Entity<Reminder>(entity =>
        {
            entity.HasKey(r => r.Id);
            entity.Property(r => r.Title).IsRequired().HasMaxLength(200);
            entity.Property(r => r.Description).HasColumnType("text");

            entity.HasOne(r => r.Project)
                  .WithMany(p => p.Reminders)
                  .HasForeignKey(r => r.ProjectId)
                  .OnDelete(DeleteBehavior.SetNull);
        });

        // ScheduledTask configuration
        modelBuilder.Entity<ScheduledTask>(entity =>
        {
            entity.HasKey(t => t.Id);
            entity.Property(t => t.Name).IsRequired().HasMaxLength(150);
            entity.Property(t => t.CronExpression).IsRequired().HasMaxLength(100);
        });
    }
}