using System.Text.Json.Serialization;

namespace Portal.Domain.Enums;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum KanbanColumnStatus
{
    Backlog = 0,
    CurrentSprint = 1,
    Ongoing = 2,
    Testing = 3,
    Done = 4,
    OnHold = 5
}