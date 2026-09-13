using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Portal.Data;
using Portal.Domain.Entities;
using Portal.DTOs.Budget;

namespace Portal.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class BudgetController : ControllerBase
{
    private readonly PortalDbContext _db;

    public BudgetController(PortalDbContext db)
    {
        _db = db;
    }

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
                          ?? throw new UnauthorizedAccessException();

    [HttpGet("overview")]
    public async Task<ActionResult<BudgetOverviewDto>> GetOverview()
    {
        var accounts = await _db.BankAccounts
            .Where(a => a.UserId == UserId)
            .OrderBy(a => a.Type)
            .ThenBy(a => a.Name)
            .Select(a => new BankAccountDto(a.Id, a.Name, a.Type, a.CurrentBalance, a.Iban))
            .ToListAsync();

        var entries = await _db.MonthlyBudgetEntries
            .Where(e => e.UserId == UserId)
            .OrderBy(e => e.DueDayOfMonth)
            .Select(e => new MonthlyEntryDto(e.Id, e.Description, e.Amount, e.Category, e.DueDayOfMonth, e.BankAccountId))
            .ToListAsync();

        var totalChecking = accounts.Where(a => a.Type == AccountType.Checking).Sum(a => a.CurrentBalance);
        var totalSavings = accounts.Where(a => a.Type == AccountType.Savings).Sum(a => a.CurrentBalance);
        var totalInvestments = accounts.Where(a => a.Type == AccountType.Investment).Sum(a => a.CurrentBalance);

        var income = entries.Where(e => e.Amount > 0).Sum(e => e.Amount);
        var expenses = entries.Where(e => e.Amount < 0).Sum(e => Math.Abs(e.Amount));

        return new BudgetOverviewDto(
            TotalBalance: totalChecking + totalSavings + totalInvestments,
            TotalChecking: totalChecking,
            TotalSavings: totalSavings,
            TotalInvestments: totalInvestments,
            TotalMonthlyIncome: income,
            TotalMonthlyExpenses: expenses,
            NetMonthlyCashflow: income - expenses,
            Accounts: accounts,
            MonthlyEntries: entries
        );
    }

    [HttpPost("accounts")]
    public async Task<ActionResult<BankAccountDto>> CreateAccount(CreateBankAccountDto dto)
    {
        var account = new BankAccount
        {
            Name = dto.Name,
            Type = dto.Type,
            CurrentBalance = dto.CurrentBalance,
            Iban = dto.Iban,
            UserId = UserId
        };

        _db.BankAccounts.Add(account);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetOverview), new BankAccountDto(account.Id, account.Name, account.Type, account.CurrentBalance, account.Iban));
    }

    [HttpPatch("accounts/{id:guid}/balance")]
    public async Task<IActionResult> UpdateBalance(Guid id, UpdateAccountBalanceDto dto)
    {
        var account = await _db.BankAccounts.FirstOrDefaultAsync(a => a.Id == id && a.UserId == UserId);
        if (account == null) return NotFound();

        account.CurrentBalance = dto.NewBalance;
        account.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return NoContent();
    }

    [HttpPost("entries")]
    public async Task<ActionResult<MonthlyEntryDto>> CreateEntry(CreateMonthlyEntryDto dto)
    {
        var entry = new MonthlyBudgetEntry
        {
            Description = dto.Description,
            Amount = dto.Amount,
            Category = dto.Category,
            DueDayOfMonth = dto.DueDayOfMonth,
            BankAccountId = dto.BankAccountId,
            UserId = UserId
        };

        _db.MonthlyBudgetEntries.Add(entry);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetOverview), new MonthlyEntryDto(entry.Id, entry.Description, entry.Amount, entry.Category, entry.DueDayOfMonth, entry.BankAccountId));
    }

    [HttpDelete("entries/{id:guid}")]
    public async Task<IActionResult> DeleteEntry(Guid id)
    {
        var entry = await _db.MonthlyBudgetEntries.FirstOrDefaultAsync(e => e.Id == id && e.UserId == UserId);
        if (entry == null) return NotFound();

        _db.MonthlyBudgetEntries.Remove(entry);
        await _db.SaveChangesAsync();

        return NoContent();
    }
}