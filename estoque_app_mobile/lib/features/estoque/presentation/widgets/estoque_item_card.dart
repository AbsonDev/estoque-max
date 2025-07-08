import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/estoque_item.dart';

class EstoqueItemCard extends StatelessWidget {
  final EstoqueItem item;
  final VoidCallback? onTap;
  final VoidCallback? onConsumirPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const EstoqueItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onConsumirPressed,
    this.onEditPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  _buildProductIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.produtoNome,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (item.produtoMarca != null)
                          Text(
                            item.produtoMarca!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildQuantityBadge(),
                ],
              ),

              const SizedBox(height: 12),

              // Informações
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.home_outlined,
                    label: item.despensaNome,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  if (item.dataValidade != null)
                    _buildInfoChip(
                      icon: Icons.calendar_month_outlined,
                      label: _formatDate(item.dataValidade!),
                      color: _getDateColor(),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Alertas
              if (_hasAlerts())
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _buildAlerts(),
                  ),
                ),

              // Ações
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.remove_circle_outline,
                      label: 'Consumir',
                      onPressed: onConsumirPressed,
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Editar',
                      onPressed: onEditPressed,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildMenuButton(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppTheme.primaryColor,
        size: 24,
      ),
    );
  }

  Widget _buildQuantityBadge() {
    final color = item.precisaRepor ? AppTheme.error : AppTheme.success;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.precisaRepor ? Icons.warning_outlined : Icons.check_circle_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${item.quantidade}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isPrimary ? AppTheme.primaryColor : AppTheme.textSecondary,
        side: BorderSide(
          color: isPrimary ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppTheme.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onSelected: (value) {
        switch (value) {
          case 'delete':
            onDeletePressed?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppTheme.error),
              const SizedBox(width: 8),
              Text('Excluir', style: TextStyle(color: AppTheme.error)),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasAlerts() {
    return item.estaVencido || item.venceEm7Dias || item.precisaRepor;
  }

  List<Widget> _buildAlerts() {
    final alerts = <Widget>[];

    if (item.estaVencido) {
      alerts.add(_buildAlertChip(
        'Vencido',
        Icons.dangerous,
        AppTheme.error,
      ));
    } else if (item.venceEm7Dias) {
      alerts.add(_buildAlertChip(
        'Vence em 7 dias',
        Icons.warning,
        Colors.orange,
      ));
    }

    if (item.precisaRepor) {
      alerts.add(_buildAlertChip(
        'Baixo estoque',
        Icons.inventory_outlined,
        AppTheme.warning,
      ));
    }

    return alerts;
  }

  Widget _buildAlertChip(String text, IconData icon, Color color) {
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
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getDateColor() {
    if (item.dataValidade == null) return AppTheme.textSecondary;
    
    if (item.estaVencido) return AppTheme.error;
    if (item.venceEm7Dias) return Colors.orange;
    
    return AppTheme.textSecondary;
  }
} 