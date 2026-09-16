import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../../tools/screens/weight_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final apiClient = ref.read(apiClientProvider);

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
                  leading: const Icon(Icons.home_outlined, color: NordColors.nord8),
                  title: const Text('Dashboard', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
                  selected: true,
                  selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () => Navigator.of(context).pop(),
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
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord4),
                  title: const Text('Financiën', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/budget');
                  },
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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