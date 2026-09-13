using Portal.Domain.Entities;

namespace Portal.DTOs.Budget;

public record BankAccountDto(Guid Id, string Name, AccountType Type, decimal CurrentBalance, string? Iban);
public record CreateBankAccountDto(string Name, AccountType Type, decimal CurrentBalance, string? Iban);
public record UpdateAccountBalanceDto(decimal NewBalance);

public record MonthlyEntryDto(Guid Id, string Description, decimal Amount, string Category, int DueDayOfMonth, Guid? BankAccountId);
public record CreateMonthlyEntryDto(string Description, decimal Amount, string Category, int DueDayOfMonth, Guid? BankAccountId);

public record BudgetOverviewDto(
    decimal TotalBalance,
    decimal TotalChecking,
    decimal TotalSavings,
    decimal TotalInvestments,
    decimal TotalMonthlyIncome,
    decimal TotalMonthlyExpenses,
    decimal NetMonthlyCashflow,
    List<BankAccountDto> Accounts,
    List<MonthlyEntryDto> MonthlyEntries
);