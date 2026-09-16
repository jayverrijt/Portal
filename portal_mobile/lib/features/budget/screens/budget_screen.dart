import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/budget_models.dart';
import '../providers/budget_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    bool isExpense = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NordColors.nord1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.add_card_outlined, color: NordColors.nord8, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Nieuwe Transactie',
                            style: TextStyle(
                              color: NordColors.nord6,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: NordColors.nord4),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Uitgave')),
                          selected: isExpense,
                          selectedColor: NordColors.nord11.withValues(alpha: 0.3),
                          backgroundColor: NordColors.nord0,
                          labelStyle: TextStyle(
                            color: isExpense ? NordColors.nord11 : NordColors.nord4,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) => setModalState(() => isExpense = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Inkomen')),
                          selected: !isExpense,
                          selectedColor: NordColors.nord14.withValues(alpha: 0.3),
                          backgroundColor: NordColors.nord0,
                          labelStyle: TextStyle(
                            color: !isExpense ? NordColors.nord14 : NordColors.nord4,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) => setModalState(() => isExpense = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    autofocus: true,
                    style: const TextStyle(color: NordColors.nord6),
                    decoration: InputDecoration(
                      labelText: 'Omschrijving (bijv. Supermarkt)',
                      labelStyle: const TextStyle(color: NordColors.nord4),
                      filled: true,
                      fillColor: NordColors.nord0,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: NordColors.nord6),
                    decoration: InputDecoration(
                      labelText: 'Bedrag (€)',
                      labelStyle: const TextStyle(color: NordColors.nord4),
                      filled: true,
                      fillColor: NordColors.nord0,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: NordColors.nord2,
                            foregroundColor: NordColors.nord6,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Annuleren'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NordColors.nord8,
                            foregroundColor: NordColors.nord0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            final desc = descController.text.trim();
                            final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
                            if (desc.isNotEmpty && amount > 0) {
                              Navigator.of(ctx).pop();
                              ref.refresh(budgetOverviewProvider);
                            }
                          },
                          child: const Text('Toevoegen', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(budgetOverviewProvider);
    final apiClient = ref.read(apiClientProvider);

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
        child: FutureBuilder<Response>(
          future: apiClient.dio.get('/UserSettings'),
          builder: (context, snapshot) {
            String displayName = 'Portal Gebruiker';
            String? profilePictureUrl;

            if (snapshot.hasData && snapshot.data?.data != null) {
              final data = snapshot.data!.data;
              displayName = data['fullName'] ?? 'Portal Gebruiker';
              if (displayName.trim().isEmpty) displayName = 'Portal Gebruiker';
              profilePictureUrl = data['profilePictureUrl'];
            }

            return Column(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: NordColors.nord0,
                    border: Border(bottom: BorderSide(color: NordColors.nord2)),
                  ),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: NordColors.nord8, width: 1.5),
                            color: NordColors.nord1,
                          ),
                          child: ClipOval(
                            child: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                                ? Image.network(
                              profilePictureUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person,
                                size: 24,
                                color: NordColors.nord4,
                              ),
                            )
                                : const Icon(
                              Icons.person,
                              size: 24,
                              color: NordColors.nord4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              color: NordColors.nord6,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home_outlined, color: NordColors.nord4),
                  title: const Text('Dashboard', style: TextStyle(color: NordColors.nord4)),
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
                  leading: const Icon(Icons.view_kanban_outlined, color: NordColors.nord4),
                  title: const Text('FlowBoards', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/flowboards');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.note_alt_outlined, color: NordColors.nord4),
                  title: const Text('Notities', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/notes');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord8),
                  title: const Text('Financiën', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
                  selected: true,
                  selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.widgets_outlined, color: NordColors.nord4),
                  title: const Text('Utils', style: TextStyle(color: NordColors.nord4)),
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
                    leading: const Icon(Icons.settings_outlined, color: NordColors.nord4),
                    title: const Text('Instellingen', style: TextStyle(color: NordColors.nord4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/settings');
                    },
                  ),
                ),
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NordColors.nord8,
        foregroundColor: NordColors.nord0,
        onPressed: () => _showAddTransactionDialog(context, ref),
        child: const Icon(Icons.add),
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