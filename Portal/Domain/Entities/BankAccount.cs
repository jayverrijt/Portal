namespace Portal.Domain.Entities;

public class BankAccount : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public AccountType Type { get; set; } = AccountType.Checking;
    public decimal CurrentBalance { get; set; }
    public string? Iban { get; set; }
    public string UserId { get; set; } = string.Empty;
}