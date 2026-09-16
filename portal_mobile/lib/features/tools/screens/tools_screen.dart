import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../budget/providers/budget_provider.dart';
import 'weight_detail_screen.dart';
import 'url_shortener_detail_screen.dart';
import 'pastebin_detail_screen.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = ref.read(apiClientProvider);

    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Text(
          "Portal Tools",
          style: TextStyle(
            color: NordColors.nord6,
            fontWeight: FontWeight.bold,
          ),
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
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord4),
                  title: const Text('Financiën', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/budget');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.widgets_outlined, color: NordColors.nord8),
                  title: const Text('Utils', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
                  selected: true,
                  selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () => Navigator.of(context).pop(),
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
          _buildToolCard(
            context,
            title: "Weight Tracker",
            subtitle: "Log je gewicht & bekijk voortgangsgrafiek",
            icon: Icons.monitor_weight_outlined,
            accentColor: NordColors.nord8,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WeightDetailScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            context,
            title: "URL Shortener",
            subtitle: "Beheer, verkort en kopieer links",
            icon: Icons.link,
            accentColor: NordColors.nord9,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UrlShortenerDetailScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            context,
            title: "Pastebin",
            subtitle: "Sla code-snippets en teksten op",
            icon: Icons.notes,
            accentColor: NordColors.nord14,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PastebinDetailScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color accentColor,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: NordColors.nord1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NordColors.nord2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: NordColors.nord6,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: NordColors.nord4,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: NordColors.nord3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}