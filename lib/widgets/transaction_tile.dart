import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? AppTheme.success : AppTheme.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.displayTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(transaction.date)} · ${transaction.category}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isIncome ? '+' : '-'}฿${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = '${date.day}'.padLeft(2, '0');
    final month = '${date.month}'.padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
