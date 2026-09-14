import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/budget_models.dart';
import '../providers/budget_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(budgetOverviewProvider);

    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord8, size: 22),
            SizedBox(width: 8),
            Text('Budget & Financiën', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold)),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: NordColors.nord4),
            onPressed: () => ref.refresh(budgetOverviewProvider),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: NordColors.nord1,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: NordColors.nord0,
                border: Border(bottom: BorderSide(color: NordColors.nord2)),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: NordColors.nord1,
                            shape: BoxShape.circle,
                            border: Border.all(color: NordColors.nord2),
                          ),
                          child: const Icon(
                            Icons.bolt,
                            color: NordColors.nord13,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Portal',
                          style: TextStyle(
                            color: NordColors.nord6,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Productivity Suite',
                      style: TextStyle(color: NordColors.nord4, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: NordColors.nord4),
              title: const Text('Home', style: TextStyle(color: NordColors.nord4)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined, color: NordColors.nord4),
              title: const Text('Projecten', style: TextStyle(color: NordColors.nord4)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/projects');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord8),
              title: const Text('Budget & Financiën', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
              selected: true,
              selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.widgets_outlined, color: NordColors.nord4),
              title: const Text('Tools', style: TextStyle(color: NordColors.nord4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/tools');
              },
            ),
            const Spacer(),
            const Divider(color: NordColors.nord2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                leading: const Icon(Icons.logout, color: NordColors.nord11),
                title: const Text('Uitloggen', style: TextStyle(color: NordColors.nord11)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(authNotifierProvider.notifier).logout();
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      body: overviewAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: NordColors.nord8),
        ),
        error: (err, _) => Center(
          child: Text('Fout bij laden budget: $err', style: const TextStyle(color: NordColors.nord11)),
        ),
        data: (overview) {
          if (overview == null) {
            return const Center(
              child: Text('Geen budgetgegevens gevonden', style: TextStyle(color: NordColors.nord3)),
            );
          }

          return RefreshIndicator(
            color: NordColors.nord8,
            backgroundColor: NordColors.nord1,
            onRefresh: () async => ref.refresh(budgetOverviewProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTotalBalanceCard(overview),
                const SizedBox(height: 12),
                _buildCashflowRow(overview),
                const SizedBox(height: 20),
                const Text(
                  'Rekeningen',
                  style: TextStyle(
                    color: NordColors.nord6,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...overview.accounts.map((acc) => _buildAccountCard(context, ref, acc)),
                const SizedBox(height: 20),
                const Text(
                  'Recente Transacties',
                  style: TextStyle(
                    color: NordColors.nord6,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (overview.monthlyEntries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text('Geen recente mutaties', style: TextStyle(color: NordColors.nord3)),
                    ),
                  )
                else
                  ...overview.monthlyEntries.map((e) => _buildEntryItem(context, ref, e)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalBalanceCard(BudgetOverviewDto overview) {
    return Card(
      color: NordColors.nord1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Totaal Vermogen',
              style: TextStyle(color: NordColors.nord4, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              '€ ${overview.totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: NordColors.nord6,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: NordColors.nord2, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSubBalance('Betaal', overview.totalChecking, NordColors.nord8),
                _buildSubBalance('Spaar', overview.totalSavings, NordColors.nord14),
                _buildSubBalance('Beleggingen', overview.totalInvestments, NordColors.nord15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubBalance(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: NordColors.nord4, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '€ ${amount.toStringAsFixed(2)}',
          style: const TextStyle(color: NordColors.nord5, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildCashflowRow(BudgetOverviewDto overview) {
    return Row(
      children: [
        Expanded(
          child: _buildCashflowCard(
            'Inkomsten',
            '€ ${overview.totalMonthlyIncome.toStringAsFixed(2)}',
            Icons.arrow_downward,
            NordColors.nord14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCashflowCard(
            'Uitgaven',
            '€ ${overview.totalMonthlyExpenses.toStringAsFixed(2)}',
            Icons.arrow_upward,
            NordColors.nord11,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCashflowCard(
            'Netto',
            '€ ${overview.netMonthlyCashflow.toStringAsFixed(2)}',
            Icons.swap_vert,
            overview.netMonthlyCashflow >= 0 ? NordColors.nord14 : NordColors.nord11,
          ),
        ),
      ],
    );
  }

  Widget _buildCashflowCard(String label, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: NordColors.nord1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: NordColors.nord4, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, WidgetRef ref, BankAccountDto acc) {
    final IconData icon = switch (acc.type) {
      AccountType.checking => Icons.payment,
      AccountType.savings => Icons.savings,
      AccountType.investments => Icons.trending_up,
    };

    final Color color = switch (acc.type) {
      AccountType.checking => NordColors.nord8,
      AccountType.savings => NordColors.nord14,
      AccountType.investments => NordColors.nord15,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: NordColors.nord1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(acc.name, style: const TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: acc.iban != null
            ? Text(acc.iban!, style: const TextStyle(color: NordColors.nord4, fontSize: 11))
            : null,
        trailing: Text(
          '€ ${acc.currentBalance.toStringAsFixed(2)}',
          style: const TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildEntryItem(BuildContext context, WidgetRef ref, BudgetEntryDto entry) {
    final color = entry.isExpense ? NordColors.nord11 : NordColors.nord14;
    final prefix = entry.isExpense ? '-' : '+';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: NordColors.nord1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: const TextStyle(color: NordColors.nord6, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                if (entry.category != null)
                  Text(
                    entry.category!,
                    style: const TextStyle(color: NordColors.nord4, fontSize: 11),
                  ),
              ],
            ),
          ),
          Text(
            '$prefix€ ${entry.amount.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}