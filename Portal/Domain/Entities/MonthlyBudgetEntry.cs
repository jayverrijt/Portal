namespace Portal.Domain.Entities;

public class MonthlyBudgetEntry : BaseEntity
{
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; } // Positief = Inkomst, Negatief = Uitgave
    public string Category { get; set; } = "Vast"; // bijv. Wonen, Verzekering, Salaris
    public int DueDayOfMonth { get; set; } = 1;
    public string UserId { get; set; } = string.Empty;
    public Guid? BankAccountId { get; set; }
    public BankAccount? BankAccount { get; set; }
}