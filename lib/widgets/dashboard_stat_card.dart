import 'package:flutter/material.dart';

import '../core/theme.dart';

class DashboardStatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const DashboardStatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '฿${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fullWidth ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
