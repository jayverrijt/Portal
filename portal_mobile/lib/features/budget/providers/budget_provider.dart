import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/budget_models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final budgetOverviewProvider = FutureProvider.autoDispose<BudgetOverviewDto?>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final response = await client.dio.get('/Budget/overview');
    if (response.statusCode == 200 && response.data != null) {
      return BudgetOverviewDto.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  } catch (e) {
    debugPrint('Fout bij ophalen Budget overview: $e');
    return null;
  }
});

class BudgetActionsNotifier extends Notifier<void> {
  late final ApiClient _client;

  @override
  void build() {
    _client = ref.watch(apiClientProvider);
  }

  Future<bool> updateAccountBalance(String accountId, double newBalance) async {
    try {
      final res = await _client.dio.patch(
        '/Budget/accounts/$accountId/balance',
        data: {'newBalance': newBalance},
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        ref.invalidate(budgetOverviewProvider);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fout bij updaten saldo: $e');
      return false;
    }
  }

  Future<bool> createEntry({
    required String description,
    required double amount,
    required bool isExpense,
    required String accountId,
    String? category,
  }) async {
    try {
      final payload = {
        'description': description,
        'amount': amount,
        'isExpense': isExpense,
        'accountId': accountId,
        'category': category,
        'date': DateTime.now().toIso8601String(),
      };
      final res = await _client.dio.post('/Budget/entries', data: payload);
      if (res.statusCode == 200 || res.statusCode == 201) {
        ref.invalidate(budgetOverviewProvider);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fout bij toevoegen entry: $e');
      return false;
    }
  }

  Future<bool> deleteEntry(String entryId) async {
    try {
      final res = await _client.dio.delete('/Budget/entries/$entryId');
      if (res.statusCode == 200 || res.statusCode == 204) {
        ref.invalidate(budgetOverviewProvider);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fout bij verwijderen entry: $e');
      return false;
    }
  }
}

final budgetActionsProvider = NotifierProvider<BudgetActionsNotifier, void>(() {
  return BudgetActionsNotifier();
});