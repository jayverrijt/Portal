import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../../tools/screens/weight_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Text(
          'Portal Dashboard',
          style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
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
              leading: const Icon(Icons.home_outlined, color: NordColors.nord8),
              title: const Text('Home', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
              selected: true,
              selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined, color: NordColors.nord4),
              title: const Text('Projecten', style: TextStyle(color: NordColors.nord4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/projects');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord4),
              title: const Text('Budget & Financiën', style: TextStyle(color: NordColors.nord4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/budget');
              },
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Weer Widget (Helmond, Netherlands)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NordColors.nord1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NordColors.nord2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Helmond, NL',
                      style: TextStyle(
                        color: NordColors.nord6,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gedeeltelijk bewolkt',
                      style: TextStyle(color: NordColors.nord4, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.wb_cloudy_outlined, color: NordColors.nord8, size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      '19°C',
                      style: TextStyle(
                        color: NordColors.nord6,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Stats Grid / Summary
          projectsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: NordColors.nord8)),
            error: (_, __) => const SizedBox.shrink(),
            data: (projects) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: NordColors.nord1,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NordColors.nord2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.folder_special, color: NordColors.nord8),
                          const SizedBox(height: 12),
                          Text(
                            '${projects.length}',
                            style: const TextStyle(color: NordColors.nord6, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text('Projecten', style: TextStyle(color: NordColors.nord4, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: NordColors.nord1,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NordColors.nord2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.note_alt, color: NordColors.nord14),
                          const SizedBox(height: 12),
                          Text(
                            '${projects.fold(0, (sum, p) => sum + p.notes.length)}',
                            style: const TextStyle(color: NordColors.nord6, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text('Notities', style: TextStyle(color: NordColors.nord4, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Snelle Snelkoppelingen naar Tools / Gewicht
          const Text(
            'Snelle Acties',
            style: TextStyle(color: NordColors.nord6, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NordColors.nord1,
                    foregroundColor: NordColors.nord8,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: NordColors.nord2),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.monitor_weight_outlined),
                  label: const Text('Gewicht Loggen'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WeightDetailScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NordColors.nord1,
                    foregroundColor: NordColors.nord14,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: NordColors.nord2),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Projecten Bekijken'),
                  onPressed: () => context.go('/projects'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}