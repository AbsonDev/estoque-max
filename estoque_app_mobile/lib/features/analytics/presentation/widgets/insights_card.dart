import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/analytics_models.dart';

class InsightsCard extends StatelessWidget {
  final String title;
  final String description;
  final double confidence;
  final TipoInsight type;
  final String? action;

  const InsightsCard({
    super.key,
    required this.title,
    required this.description,
    required this.confidence,
    required this.type,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getTypeColor().withOpacity(0.2), width: 1),
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
                  color: _getTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Confiança: ${(confidence * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTypeLabel(),
                  style: TextStyle(
                    color: _getTypeColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: AppTheme.textSecondary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(_getTypeColor()),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (type) {
      case TipoInsight.geral:
        return AppTheme.primaryColor;
      case TipoInsight.economia:
        return AppTheme.success;
      case TipoInsight.desperdicio:
        return AppTheme.error;
      case TipoInsight.tendencia:
        return AppTheme.warning;
      case TipoInsight.alerta:
        return AppTheme.error;
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case TipoInsight.geral:
        return Icons.info_outline;
      case TipoInsight.economia:
        return Icons.savings;
      case TipoInsight.desperdicio:
        return Icons.warning_amber;
      case TipoInsight.tendencia:
        return Icons.trending_up;
      case TipoInsight.alerta:
        return Icons.priority_high;
    }
  }

  String _getTypeLabel() {
    switch (type) {
      case TipoInsight.geral:
        return 'Geral';
      case TipoInsight.economia:
        return 'Economia';
      case TipoInsight.desperdicio:
        return 'Desperdício';
      case TipoInsight.tendencia:
        return 'Tendência';
      case TipoInsight.alerta:
        return 'Alerta';
    }
  }
}
