namespace Portal.DTOs.ScheduledTasks;

public class ScheduledTaskDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string CronExpression { get; set; } = string.Empty;
    public DateTime? LastRunAt { get; set; }
    public DateTime NextRunAt { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}