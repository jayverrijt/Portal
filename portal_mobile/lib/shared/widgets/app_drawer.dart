import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/theme/nord_theme.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/budget/providers/budget_provider.dart';

class AppDrawer extends ConsumerWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = ref.read(apiClientProvider);

    return Drawer(
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
              _buildDrawerItem(
                context,
                icon: Icons.home_outlined,
                title: 'Dashboard',
                route: '/home',
              ),
              _buildDrawerItem(
                context,
                icon: Icons.folder_outlined,
                title: 'Projecten',
                route: '/projects',
              ),
              _buildDrawerItem(
                context,
                icon: Icons.view_kanban_outlined,
                title: 'FlowBoards',
                route: '/flowboards',
              ),
              _buildDrawerItem(
                context,
                icon: Icons.note_alt_outlined,
                title: 'Notities',
                route: '/notes',
              ),
              _buildDrawerItem(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Financiën',
                route: '/budget',
              ),
              _buildDrawerItem(
                context,
                icon: Icons.widgets_outlined,
                title: 'Utils',
                route: '/tools',
              ),
              const Spacer(),
              const Divider(color: NordColors.nord2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Instellingen',
                  route: '/settings',
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
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String route,
      }) {
    final bool isSelected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? NordColors.nord8 : NordColors.nord4,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? NordColors.nord6 : NordColors.nord4,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          Navigator.of(context).pop();
          if (!isSelected) {
            context.go(route);
          }
        },
      ),
    );
  }
}