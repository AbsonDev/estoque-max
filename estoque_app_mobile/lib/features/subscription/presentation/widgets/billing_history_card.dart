import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/subscription_models.dart';

class BillingHistoryCard extends StatelessWidget {
  final SubscriptionHistory history;

  const BillingHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
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
              Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  history.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                NumberFormat.currency(
                  locale: 'pt_BR',
                  symbol: 'R\$',
                ).format(history.amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(history.date),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (history.description != null &&
              history.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              history.description!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (history.status.toLowerCase()) {
      case 'paid':
      case 'pago':
        return AppTheme.success;
      case 'pending':
      case 'pendente':
        return AppTheme.warning;
      case 'failed':
      case 'falhou':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (history.status.toLowerCase()) {
      case 'paid':
      case 'pago':
        return Icons.check_circle;
      case 'pending':
      case 'pendente':
        return Icons.schedule;
      case 'failed':
      case 'falhou':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusText() {
    switch (history.status.toLowerCase()) {
      case 'paid':
        return 'Pago';
      case 'pago':
        return 'Pago';
      case 'pending':
        return 'Pendente';
      case 'pendente':
        return 'Pendente';
      case 'failed':
        return 'Falhou';
      case 'falhou':
        return 'Falhou';
      default:
        return history.status;
    }
  }
}
