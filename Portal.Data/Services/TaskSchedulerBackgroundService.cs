using Cronos;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Portal.Domain.Interfaces;

namespace Portal.Data.Services;

public class TaskSchedulerBackgroundService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<TaskSchedulerBackgroundService> _logger;

    public TaskSchedulerBackgroundService(
        IServiceScopeFactory scopeFactory,
        ILogger<TaskSchedulerBackgroundService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Scheduled Task Background Engine is gestart.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessPendingTasksAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Er is een fout opgetreden tijdens de verwerking van scheduled tasks.");
            }

            // Controleer elke 30 seconden op taken die uitgevoerd moeten worden
            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
        }
    }

    private async Task ProcessPendingTasksAsync()
    {
        using var scope = _scopeFactory.CreateScope();
        var unitOfWork = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();

        var now = DateTime.UtcNow;
        var dueTasks = await unitOfWork.ScheduledTasks.FindAsync(t => t.IsActive && t.NextRunAt <= now);

        foreach (var task in dueTasks)
        {
            _logger.LogInformation("Taak uitvoeren: {TaskName} (ID: {TaskId})", task.Name, task.Id);

            // --- HIER KOMT DE EXECUTION LOGIC (bijv. Webhook, Notificatie, Sync) ---
            // Voor nu simuleren we succesvolle uitvoering:
            task.LastRunAt = DateTime.UtcNow;

            // Nieuwe NextRunAt berekenen op basis van de CronExpression
            try
            {
                var expression = CronExpression.Parse(task.CronExpression);
                var next = expression.GetNextOccurrence(DateTime.UtcNow);

                if (next.HasValue)
                {
                    task.NextRunAt = next.Value;
                }
                else
                {
                    // Geen volgende datum meer (bijv. verlopen schema)
                    task.IsActive = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ongeldige CronExpression voor task {TaskId}", task.Id);
                task.IsActive = false;
            }

            unitOfWork.ScheduledTasks.Update(task);
        }

        await unitOfWork.CompleteAsync();
    }
}