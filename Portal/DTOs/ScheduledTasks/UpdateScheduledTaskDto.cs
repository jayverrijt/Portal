namespace Portal.DTOs.ScheduledTasks;

public class UpdateScheduledTaskDto
{
    public string Name { get; set; } = string.Empty;
    public string CronExpression { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}