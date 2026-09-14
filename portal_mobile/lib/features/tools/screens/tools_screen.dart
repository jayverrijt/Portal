import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import 'weight_detail_screen.dart';
import 'url_shortener_detail_screen.dart';
import 'pastebin_detail_screen.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              leading: const Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord4),
              title: const Text('Budget & Financiën', style: TextStyle(color: NordColors.nord4)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/budget');
              },
            ),
            ListTile(
              leading: const Icon(Icons.widgets_outlined, color: NordColors.nord8),
              title: const Text('Tools', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
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