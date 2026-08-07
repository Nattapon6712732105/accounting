import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/model.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int index)? onQuickAction;

  const DashboardScreen({super.key, this.onQuickAction});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SummaryModel? _summary;
  List<TransactionModel> _recent = [];
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

  String get _currentMonth {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = ApiService.token;
      if (token == null) throw Exception('กรุณาล็อกอินก่อนใช้งาน');

      final report = await ApiService.getReportsSummary(token: token, month: _currentMonth);
      final txn = await ApiService.getTransactions(token: token, limit: 4);
      if (!mounted) return;
      setState(() {
        _summary = report['summary'] as SummaryModel?;
        _recent = (txn['transactions'] as List<TransactionModel>).toList();
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

    final summary = _summary ??
        SummaryModel(totalIncome: 0, totalExpense: 0, balance: 0);

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สรุปยอดเดือนนี้',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    label: 'รายรับ',
                    amount: summary.totalIncome,
                    icon: Icons.trending_up,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    label: 'รายจ่าย',
                    amount: summary.totalExpense,
                    icon: Icons.trending_down,
                    color: AppTheme.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DashboardStatCard(
              label: 'คงเหลือ',
              amount: summary.balance,
              icon: Icons.account_balance_wallet,
              color: AppTheme.accent,
              fullWidth: true,
            ),
            const SizedBox(height: 24),
            const Text(
              'การเข้าถึงด่วน',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _quickAction(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'เพิ่มรายการ',
                  color: AppTheme.accent,
                  onTap: () => Navigator.pushNamed(context, '/add_transaction'),
                ),
                _quickAction(
                  context,
                  icon: Icons.receipt_long_outlined,
                  label: 'รายการบัญชี',
                  color: AppTheme.success,
                  onTap: () => widget.onQuickAction?.call(1),
                ),
                _quickAction(
                  context,
                  icon: Icons.category_outlined,
                  label: 'หมวดหมู่',
                  color: AppTheme.primary,
                  onTap: () => widget.onQuickAction?.call(2),
                ),
                _quickAction(
                  context,
                  icon: Icons.refresh,
                  label: 'รีเฟรช',
                  color: const Color(0xFF7C3AED),
                  onTap: _load,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'รายการล่าสุด',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            if (_recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text('ยังไม่มีรายการ', style: TextStyle(color: AppTheme.textMuted)),
                ),
              )
            else
              ..._recent.map((t) => TransactionTile(transaction: t)),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMain),
          ),
        ],
      ),
    );
  }
}
