import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const AppDrawer({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: AppTheme.luxuryGradient),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_balance, size: 32, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'ENTERPRISE ACCOUNTING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ระบบจัดการรายรับ-รายจ่าย',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _menuItem(context, index: 0, icon: Icons.dashboard_outlined, label: 'ภาพรวม'),
          _menuItem(context, index: 1, icon: Icons.receipt_long_outlined, label: 'รายการบัญชี'),
          _menuItem(context, index: 2, icon: Icons.category_outlined, label: 'หมวดหมู่'),
          _menuItem(context, index: 3, icon: Icons.person_outline, label: 'โปรไฟล์'),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: AppTheme.goldDark),
            title: const Text('เพิ่มรายการใหม่'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add_transaction');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('ตั้งค่า'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.danger),
            title: const Text('ออกจากระบบ', style: TextStyle(color: AppTheme.danger)),
            onTap: () async {
              final token = ApiService.token;
              if (token != null) {
                try {
                  await ApiService.logout(token);
                } catch (_) {}
              }
              ApiService.token = null;
              await TokenStorage.clear();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, {required int index, required IconData icon, required String label}) {
    final selected = currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? AppTheme.accent : null),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppTheme.accent : null,
          fontWeight: selected ? FontWeight.bold : null,
        ),
      ),
      selected: selected,
      selectedTileColor: AppTheme.accent.withValues(alpha: 0.08),
      onTap: () => onTap(index),
    );
  }
}
