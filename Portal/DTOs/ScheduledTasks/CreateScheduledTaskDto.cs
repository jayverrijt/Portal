namespace Portal.DTOs.ScheduledTasks;

public class CreateScheduledTaskDto
{
    public string Name { get; set; } = string.Empty;

    // Bijv: "0 * * * *" (Elk uur) of "*/5 * * * *" (Om de 5 minuten)
    public string CronExpression { get; set; } = string.Empty;
}