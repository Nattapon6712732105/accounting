import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/model.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<TransactionModel> _transactions = [];
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
      final result = await ApiService.getTransactions(token: token);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorView(message: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              const Text(
                'รายการทั้งหมด',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_transactions.length} รายการ',
                  style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_transactions.isEmpty)
            const _EmptyView()
          else
            ..._transactions.map((t) => TransactionTile(transaction: t)),
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
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.receipt_long, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          const Text('ยังไม่มีรายการ', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          const Text('กดปุ่มเพิ่มรายการจากเมนูเพื่อเริ่มต้น', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}
