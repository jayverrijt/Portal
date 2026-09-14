import 'account_type.dart';

class BankAccountDto {
  final String id;
  final String name;
  final AccountType type;
  final double currentBalance;
  final String? iban;

  BankAccountDto({
    required this.id,
    required this.name,
    required this.type,
    required this.currentBalance,
    this.iban,
  });

  factory BankAccountDto.fromJson(Map<String, dynamic> json) {
    AccountType parseType(dynamic val) {
      if (val is int) {
        switch (val) {
          case 0:
            return AccountType.checking;
          case 1:
            return AccountType.savings;
          case 2:
            return AccountType.investments;
          default:
            return AccountType.checking;
        }
      }
      final str = val?.toString().toLowerCase() ?? '';
      if (str.contains('sav')) return AccountType.savings;
      if (str.contains('invest')) return AccountType.investments;
      return AccountType.checking;
    }

    return BankAccountDto(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      name: (json['name'] ?? json['Name'])?.toString() ?? 'Onbekende rekening',
      type: parseType(json['type'] ?? json['Type']),
      currentBalance: (json['currentBalance'] ?? json['CurrentBalance'] ?? 0).toDouble(),
      iban: (json['iban'] ?? json['Iban'])?.toString(),
    );
  }
}