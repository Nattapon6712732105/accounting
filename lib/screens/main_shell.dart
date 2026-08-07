import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/app_drawer.dart';
import 'categories_screen.dart';
import 'dashboard_screen.dart';
import 'profile/profile.dart';
import 'transactions_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    'ภาพรวม',
    'รายการบัญชี',
    'หมวดหมู่',
    'โปรไฟล์',
  ];

  late final List<Widget> _pages = [
    DashboardScreen(onQuickAction: _selectTab),
    const TransactionsScreen(),
    const CategoriesScreen(),
    const ProfileScreen(showAppBar: false),
  ];

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onTap: (index) {
          _selectTab(index);
          Navigator.pop(context);
        },
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectTab,
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.accent.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'ภาพรวม',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'รายการ',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'หมวดหมู่',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
