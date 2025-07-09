import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class EstoqueStatsCard extends StatelessWidget {
  final int totalItems;
  final int itensVencidos;
  final int itensVencendo;
  final int itensBaixoEstoque;
  final int itensEmFalta;

  const EstoqueStatsCard({
    super.key,
    required this.totalItems,
    required this.itensVencidos,
    required this.itensVencendo,
    required this.itensBaixoEstoque,
    required this.itensEmFalta,
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
          // Título
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumo do Estoque',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Estatísticas principais
          Center(
            child: _buildStatItem(
              context,
              icon: Icons.inventory_2,
              label: 'Total de Itens',
              value: totalItems.toString(),
              color: AppTheme.primaryColor,
            ),
          ),

          // Estatísticas de alerta
          if (itensVencidos > 0 ||
              itensVencendo > 0 ||
              itensBaixoEstoque > 0 ||
              itensEmFalta > 0)
            Column(
              children: [
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Alertas
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (itensVencidos > 0)
                      _buildAlertChip(
                        context,
                        icon: Icons.warning,
                        label: 'Vencidos',
                        value: itensVencidos,
                        color: AppTheme.error,
                      ),
                    if (itensVencendo > 0)
                      _buildAlertChip(
                        context,
                        icon: Icons.schedule,
                        label: 'Vencendo',
                        value: itensVencendo,
                        color: Colors.orange,
                      ),
                    if (itensBaixoEstoque > 0)
                      _buildAlertChip(
                        context,
                        icon: Icons.trending_down,
                        label: 'Baixo Estoque',
                        value: itensBaixoEstoque,
                        color: AppTheme.warning,
                      ),
                    if (itensEmFalta > 0)
                      _buildAlertChip(
                        context,
                        icon: Icons.remove_circle,
                        label: 'Em Falta',
                        value: itensEmFalta,
                        color: AppTheme.error,
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
