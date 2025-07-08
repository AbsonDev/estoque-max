import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class KPICard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final double? change;
  final Color color;
  final IconData icon;

  const KPICard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.change,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getChangeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getChangeIcon(),
                        color: _getChangeColor(),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${change!.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _getChangeColor(),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatValue(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatValue() {
    if (unit == 'R\$') {
      return NumberFormat.currency(
        locale: 'pt_BR',
        symbol: 'R\$',
        decimalDigits: 0,
      ).format(value);
    } else if (value >= 1000) {
      return NumberFormat.compact(locale: 'pt_BR').format(value);
    } else {
      return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
    }
  }

  Color _getChangeColor() {
    if (change == null) return AppTheme.textSecondary;
    return change! >= 0 ? AppTheme.success : AppTheme.error;
  }

  IconData _getChangeIcon() {
    if (change == null) return Icons.trending_flat;
    return change! >= 0 ? Icons.trending_up : Icons.trending_down;
  }
} 