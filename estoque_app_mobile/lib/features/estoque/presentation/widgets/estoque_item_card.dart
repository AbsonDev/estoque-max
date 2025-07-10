import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/estoque_item.dart';

class EstoqueItemCard extends StatelessWidget {
  final EstoqueItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onConsume;
  final VoidCallback onDelete;

  const EstoqueItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onConsume,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onConsume(),
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              icon: Icons.remove_circle_outline,
              label: 'Consumir',
            ),
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppTheme.warning,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Editar',
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Remover',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(item.statusColor).withOpacity(0.3),
                width: 2,
              ),
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
                // Header com nome e status
                Row(
                  children: [
                    // Ícone da categoria
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(item.statusColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '📦', // Ícone padrão
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Nome e marca
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.produto,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Tag da despensa
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.despensaNome,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (item.marca != null && item.marca!.isNotEmpty)
                            Text(
                              item.marca!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                        ],
                      ),
                    ),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(item.statusColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Informações principais
                Row(
                  children: [
                    // Quantidade
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        icon: Icons.inventory_2,
                        label: 'Quantidade',
                        value:
                            '${item.quantidade.toStringAsFixed(item.quantidade.truncateToDouble() == item.quantidade ? 0 : 1)} un.',
                        color: AppTheme.primaryColor,
                      ),
                    ),

                    // Validade
                    if (item.dataValidade != null)
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          icon: Icons.schedule,
                          label: 'Validade',
                          value: DateFormat(
                            'dd/MM/yyyy',
                          ).format(item.dataValidade!),
                          color: _getValidityColor(),
                        ),
                      ),
                  ],
                ),

                // Alertas
                if (item.isVencido ||
                    item.isVencendoEm7Dias ||
                    item.isQuantidadeBaixa ||
                    item.isEmFalta)
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (item.isVencido)
                            _buildAlertChip(
                              context,
                              icon: Icons.warning,
                              label: 'Vencido',
                              color: AppTheme.error,
                            ),
                          if (item.isVencendoEm7Dias)
                            _buildAlertChip(
                              context,
                              icon: Icons.schedule,
                              label: 'Vencendo',
                              color: Colors.orange,
                            ),
                          if (item.isEmFalta)
                            _buildAlertChip(
                              context,
                              icon: Icons.remove_circle,
                              label: 'Em falta',
                              color: AppTheme.error,
                            ),
                          if (item.isQuantidadeBaixa && !item.isEmFalta)
                            _buildAlertChip(
                              context,
                              icon: Icons.trending_down,
                              label: 'Baixo estoque',
                              color: AppTheme.warning,
                            ),
                          if (item.estoqueAbaixoDoMinimo)
                            _buildAlertChip(
                              context,
                              icon: Icons.shopping_cart,
                              label: 'Precisa repor',
                              color: AppTheme.secondary,
                            ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (item.isVencido) return 'Vencido';
    if (item.isVencendoEm7Dias) return 'Vencendo';
    if (item.isEmFalta) return 'Em Falta';
    if (item.isQuantidadeBaixa) return 'Baixo';
    return 'Normal';
  }

  Color _getValidityColor() {
    if (item.isVencido) return AppTheme.error;
    if (item.isVencendoEm7Dias) return Colors.orange;
    return AppTheme.textSecondary;
  }
}
