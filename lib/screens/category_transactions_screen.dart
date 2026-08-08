import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/model.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import '../widgets/transaction_tile.dart';

class CategoryTransactionsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String type;
  final IconData icon;
  final Color color;

  const CategoryTransactionsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.icon,
    required this.color,
  });

  @override
  State<CategoryTransactionsScreen> createState() =>
      _CategoryTransactionsScreenState();
}

class _CategoryTransactionsScreenState extends State<CategoryTransactionsScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _error;

  bool get _isIncome => widget.type == 'income';

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
      final result = await ApiService.getTransactions(
        token: token,
        type: widget.type,
        category: widget.categoryId,
      );
      if (!mounted) return;
      setState(() {
        _transactions = (result['transactions'] as List<TransactionModel>).toList();
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

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openEdit(TransactionModel t) async {
    await Navigator.pushNamed(context, '/add_transaction', arguments: t);
  }

  Future<bool> _confirmDelete(TransactionModel t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: AppTheme.danger),
            SizedBox(width: 8),
            Text('ลบรายการ', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'ต้องการลบรายการ "${t.displayTitle}" จำนวน ฿${formatAmount(t.amount)} หรือไม่? '
          'การลบไม่สามารถย้อนกลับได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบรายการ'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _deleteTransaction(TransactionModel t) async {
    try {
      await ApiService.deleteTransaction(token: ApiService.token!, id: t.id);
      AppState.notifyTransactionsChanged();
      _showSnack('ลบรายการสำเร็จ');
    } catch (e) {
      _showSnack('ลบไม่สำเร็จ: ${e.toString().replaceAll('Exception: ', '')}');
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.categoryName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: _error != null
          ? _ErrorView(message: _error!, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(child: _buildHeader()),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: _transactions.isEmpty
                        ? SliverToBoxAdapter(
                            child: _EmptyView(type: widget.type),
                          )
                        : SliverList.builder(
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final t = _transactions[index];
                              return Dismissible(
                                key: ValueKey(t.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.dangerGradient,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                confirmDismiss: (_) => _confirmDelete(t),
                                onDismissed: (_) => _deleteTransaction(t),
                                child: TransactionTile(
                                  transaction: t,
                                  onTap: () => _openEdit(t),
                                  onLongPress: () => _openEdit(t),
                                  onDelete: () async {
                                    if (await _confirmDelete(t)) {
                                      await _deleteTransaction(t);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final total = _transactions.fold<double>(0, (sum, t) => sum + t.amount);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.luxuryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: AppTheme.goldGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.categoryName} · ${_isIncome ? 'รายรับ' : 'รายจ่าย'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_transactions.length} รายการ',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'รวมยอด',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '฿${formatAmount(total)}',
                  style: const TextStyle(
                    color: AppTheme.goldLight,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String type;

  const _EmptyView({required this.type});

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppTheme.goldGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.trending_up : Icons.trending_down,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีรายการในหมวดหมู่นี้',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'กดปุ่มเพิ่มรายการเพื่อเริ่มต้น',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
