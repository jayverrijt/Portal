class BudgetEntryDto {
  final String id;
  final String description;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final String? category;
  final String? accountId;

  BudgetEntryDto({
    required this.id,
    required this.description,
    required this.amount,
    required this.isExpense,
    required this.date,
    this.category,
    this.accountId,
  });

  factory BudgetEntryDto.fromJson(Map<String, dynamic> json) {
    return BudgetEntryDto(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      description: (json['description'] ?? json['Description'] ?? json['name'] ?? json['Name'])?.toString() ?? '',
      amount: (json['amount'] ?? json['Amount'] ?? 0).toDouble().abs(),
      isExpense: (json['isExpense'] ?? json['IsExpense'] ?? true) as bool,
      date: DateTime.tryParse((json['date'] ?? json['Date'] ?? json['createdAt'] ?? json['CreatedAt'])?.toString() ?? '') ??
          DateTime.now(),
      category: (json['category'] ?? json['Category'])?.toString(),
      accountId: (json['accountId'] ?? json['AccountId'])?.toString(),
    );
  }
}