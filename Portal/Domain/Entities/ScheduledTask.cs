namespace Portal.Domain.Entities;

public class ScheduledTask : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string CronExpression { get; set; } = string.Empty;
    public DateTime? LastRunAt { get; set; }
    public DateTime NextRunAt { get; set; }
    public bool IsActive { get; set; } = true;
}