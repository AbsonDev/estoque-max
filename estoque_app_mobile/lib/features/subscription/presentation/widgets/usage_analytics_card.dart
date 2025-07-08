import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/subscription_models.dart';

class UsageAnalyticsCard extends StatelessWidget {
  final SubscriptionAnalytics analytics;

  const UsageAnalyticsCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Uso do Plano',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Despensas
          _buildUsageItem(
            'Despensas',
            analytics.totalDespensas,
            analytics.limiteDespensas,
            Icons.store,
          ),
          const SizedBox(height: 12),
          
          // Itens
          _buildUsageItem(
            'Itens no Estoque',
            analytics.totalItensEstoque,
            analytics.limiteItensEstoque,
            Icons.inventory,
          ),
          const SizedBox(height: 12),
          
          // Membros
          _buildUsageItem(
            'Membros',
            analytics.totalMembros,
            analytics.limiteMembros,
            Icons.people,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String label, int used, int limit, IconData icon) {
    final progress = limit > 0 ? used / limit : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Text(
              '$used/${limit == 0 ? '∞' : limit}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.textSecondary.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 0.8 ? AppTheme.error : AppTheme.primaryColor,
          ),
          minHeight: 6,
        ),
      ],
    );
  }
} 