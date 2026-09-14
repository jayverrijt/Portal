import 'package:flutter/material.dart';
import '../../../core/theme/nord_theme.dart';
import '../../projects/screens/projects_screen.dart';
import '../../budget/screens/budget_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ProjectsScreen(),
    BudgetScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: NordColors.nord1,
        indicatorColor: NordColors.nord8.withValues(alpha: 0.2),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined, color: NordColors.nord4),
            selectedIcon: Icon(Icons.folder, color: NordColors.nord8),
            label: 'Projecten',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord4),
            selectedIcon: Icon(Icons.account_balance_wallet, color: NordColors.nord8),
            label: 'Budget',
          ),
        ],
      ),
    );
  }
}