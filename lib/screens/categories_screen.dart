import 'package:flutter/material.dart';

import '../core/category_icons.dart';
import '../core/theme.dart';
import '../models/model.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import '../widgets/breakdown_section.dart';
import '../widgets/category_grid_item.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<CategoryModel> _income = [];
  List<CategoryModel> _expense = [];
  List<CategoryBreakdownModel> _breakdown = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    AppState.transactionsChanged.addListener(_onDataChanged);
    _load();
  }

  @override
  void dispose() {
    AppState.transactionsChanged.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => _load();

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = ApiService.token;
      if (token == null) throw Exception('กรุณาล็อกอินก่อนใช้งาน');

      final result = await ApiService.getCategories();
      final report = await ApiService.getReportsSummary(token: token);
      if (!mounted) return;
      setState(() {
        _income = result['income'] ?? [];
        _expense = result['expense'] ?? [];
        _breakdown = report['categoryBreakdown'] as List<CategoryBreakdownModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppTheme.textMuted),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('ลองอีกครั้ง'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const Text(
            'กราฟสรุปตามหมวดหมู่',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          const SizedBox(height: 4),
          const Text(
            'แสดงยอดรวมทั้งหมด รายรับ-รายจ่ายในกราฟเดียวกัน',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          BreakdownSection(
            title: 'รายรับ-รายจ่าย ตามหมวดหมู่',
            subtitle: 'รายรับสีเขียว · รายจ่ายสีแดง',
            icon: Icons.pie_chart_outline,
            items: _breakdown,
          ),
          const SizedBox(height: 12),
          const Text(
            'หมวดหมู่รายรับ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          const SizedBox(height: 8),
          if (_income.isEmpty)
            const Text('ไม่มีหมวดหมู่', style: TextStyle(color: AppTheme.textMuted))
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _income
                  .map(
                    (c) => CategoryGridItem(
                      name: c.name,
                      icon: categoryIcon(c.icon),
                      color: AppTheme.success,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 24),
          const Text(
            'หมวดหมู่รายจ่าย',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          const SizedBox(height: 8),
          if (_expense.isEmpty)
            const Text('ไม่มีหมวดหมู่', style: TextStyle(color: AppTheme.textMuted))
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _expense
                  .map(
                    (c) => CategoryGridItem(
                      name: c.name,
                      icon: categoryIcon(c.icon),
                      color: AppTheme.danger,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
