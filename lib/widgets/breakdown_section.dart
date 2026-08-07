import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/model.dart';

class BreakdownSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<CategoryBreakdownModel> items;

  const BreakdownSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.subtitle = '',
  });

  Color _colorFor(CategoryBreakdownModel item, int indexInType) {
    if (item.type == 'income') {
      final lightness = 0.40 + (indexInType % 4) * 0.10;
      return HSLColor.fromAHSL(1, 142, 0.70, lightness).toColor();
    }
    final lightness = 0.42 + (indexInType % 4) * 0.10;
    return HSLColor.fromAHSL(1, 0, 0.70, lightness).toColor();
  }

  List<_Slice> _buildSlices() {
    final sorted = [...items]..sort((a, b) => b.total.compareTo(a.total));
    var incomeIndex = 0;
    var expenseIndex = 0;
    final slices = <_Slice>[];
    for (final item in sorted) {
      final isIncome = item.type == 'income';
      final color = _colorFor(item, isIncome ? incomeIndex : expenseIndex);
      if (isIncome) {
        incomeIndex++;
      } else {
        expenseIndex++;
      }
      slices.add(_Slice(item: item, color: color));
    }
    return slices;
  }

  @override
  Widget build(BuildContext context) {
    final slices = _buildSlices();
    final total = slices.fold<double>(0, (sum, s) => sum + s.item.total);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  color: AppTheme.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.accent, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (slices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'ยังไม่มีข้อมูลรายการ',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
            )
          else ...[
            _buildLegend(),
            const SizedBox(height: 16),
            _DonutChart(slices: slices, total: total),
            const SizedBox(height: 20),
            ..._buildRankedList(slices, total),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(color: const Color(0xFF16A34A), label: 'รายรับ'),
        const SizedBox(width: 20),
        _legendItem(color: const Color(0xFFDC2626), label: 'รายจ่าย'),
      ],
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMain),
        ),
      ],
    );
  }

  List<Widget> _buildRankedList(List<_Slice> slices, double total) {
    final top = slices.take(8).toList();
    final rest = slices.skip(8).toList();
    final restTotal = rest.fold<double>(0, (sum, s) => sum + s.item.total);

    return [
      for (var i = 0; i < top.length; i++) ...[
        _RankRow(
          rank: i + 1,
          item: top[i].item,
          color: top[i].color,
          total: total,
        ),
        if (i != top.length - 1) const SizedBox(height: 10),
      ],
      if (restTotal > 0) ...[
        const SizedBox(height: 10),
        Text(
          'และอื่น ๆ อีก ${rest.length} หมวดหมู่ รวม ฿${restTotal.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      ],
    ];
  }
}

class _Slice {
  final CategoryBreakdownModel item;
  final Color color;

  const _Slice({required this.item, required this.color});
}

class _DonutChart extends StatelessWidget {
  final List<_Slice> slices;
  final double total;

  const _DonutChart({required this.slices, required this.total});

  @override
  Widget build(BuildContext context) {
    const maxSlices = 6;
    final shown = slices.take(maxSlices).toList();
    final rest = slices.skip(maxSlices).toList();
    final values = <double>[...shown.map((s) => s.item.total)];
    final colors = <Color>[...shown.map((s) => s.color)];
    if (rest.isNotEmpty) {
      values.add(rest.fold<double>(0, (a, b) => a + b.item.total));
      colors.add(const Color(0xFF94A3B8));
    }

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          SizedBox(
            width: 170,
            height: 170,
            child: CustomPaint(
              painter: _DonutPainter(
                values: values,
                colors: colors,
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'รวมทั้งหมด',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '฿${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < shown.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[i],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              shown[i].item.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMain,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(values[i] / total * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (rest.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors.last,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'อื่น ๆ',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMain,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(values.last / total * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final int rank;
  final CategoryBreakdownModel item;
  final Color color;
  final double total;

  const _RankRow({
    required this.rank,
    required this.item,
    required this.color,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? item.total / total : 0.0;
    final isIncome = item.type == 'income';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$rank',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMain,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '฿${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(percent * 100).toStringAsFixed(1)}% · ${isIncome ? 'รายรับ' : 'รายจ่าย'} · ${item.count} รายการ',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final Color backgroundColor;

  _DonutPainter({
    required this.values,
    required this.colors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 30.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * math.pi, false, bgPaint);

    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    final gap = values.length > 1 ? 0.03 : 0.0;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweep = 2 * math.pi * values[i] / total;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, start, sweep - gap, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.colors != colors ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
