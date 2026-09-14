import 'bank_account_dto.dart';
import 'budget_entry_dto.dart';

class BudgetOverviewDto {
  final double totalBalance;
  final double totalChecking;
  final double totalSavings;
  final double totalInvestments;
  final double totalMonthlyIncome;
  final double totalMonthlyExpenses;
  final double netMonthlyCashflow;
  final List<BankAccountDto> accounts;
  final List<BudgetEntryDto> monthlyEntries;

  BudgetOverviewDto({
    required this.totalBalance,
    required this.totalChecking,
    required this.totalSavings,
    required this.totalInvestments,
    required this.totalMonthlyIncome,
    required this.totalMonthlyExpenses,
    required this.netMonthlyCashflow,
    required this.accounts,
    required this.monthlyEntries,
  });

  factory BudgetOverviewDto.fromJson(Map<String, dynamic> json) {
    final rawAccounts = (json['accounts'] ?? json['Accounts']) as List? ?? [];
    final rawEntries = (json['monthlyEntries'] ?? json['MonthlyEntries']) as List? ?? [];

    return BudgetOverviewDto(
      totalBalance: (json['totalBalance'] ?? json['TotalBalance'] ?? 0).toDouble(),
      totalChecking: (json['totalChecking'] ?? json['TotalChecking'] ?? 0).toDouble(),
      totalSavings: (json['totalSavings'] ?? json['TotalSavings'] ?? 0).toDouble(),
      totalInvestments: (json['totalInvestments'] ?? json['TotalInvestments'] ?? 0).toDouble(),
      totalMonthlyIncome: (json['totalMonthlyIncome'] ?? json['TotalMonthlyIncome'] ?? 0).toDouble(),
      totalMonthlyExpenses: (json['totalMonthlyExpenses'] ?? json['TotalMonthlyExpenses'] ?? 0).toDouble(),
      netMonthlyCashflow: (json['netMonthlyCashflow'] ?? json['NetMonthlyCashflow'] ?? 0).toDouble(),
      accounts: rawAccounts.map((a) => BankAccountDto.fromJson(a as Map<String, dynamic>)).toList(),
      monthlyEntries: rawEntries.map((e) => BudgetEntryDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}