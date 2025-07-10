import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/estoque_item.dart';

class EstoqueCompactCard extends StatelessWidget {
  final EstoqueItem item;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onConsume;
  final VoidCallback? onDelete;

  const EstoqueCompactCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onEdit,
    this.onConsume,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onConsume != null)
            SlidableAction(
              onPressed: (_) => onConsume!(),
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              icon: Icons.remove_circle_outline,
              label: 'Consumir',
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(item.statusColor).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com status e quantidade
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(item.statusColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  
                  // Quantidade em destaque
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.quantidade}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Nome do produto
              Text(
                item.produto,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Marca (se existir)
              if (item.marca != null && item.marca!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.marca!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Informações da despensa
              Row(
                children: [
                  Icon(
                    Icons.store,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.despensaNome,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // Data de validade (se aplicável)
              if (item.dataValidade != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: _getValidityColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yy').format(item.dataValidade!),
                      style: TextStyle(
                        color: _getValidityColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Alerta principal (se existir)
              if (_hasAlert()) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAlertColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getAlertText(),
                    style: TextStyle(
                      color: _getAlertColor(),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasAlert() {
    return item.isVencido || item.isVencendoEm7Dias || item.isEmFalta || item.estoqueAbaixoDoMinimo;
  }

  String _getAlertText() {
    if (item.isVencido) return 'VENCIDO';
    if (item.isVencendoEm7Dias) return 'VENCENDO';
    if (item.isEmFalta) return 'EM FALTA';
    if (item.estoqueAbaixoDoMinimo) return 'BAIXO ESTOQUE';
    return '';
  }

  Color _getAlertColor() {
    if (item.isVencido) return AppTheme.error;
    if (item.isVencendoEm7Dias) return Colors.orange;
    if (item.isEmFalta) return AppTheme.error;
    if (item.estoqueAbaixoDoMinimo) return AppTheme.warning;
    return AppTheme.textSecondary;
  }

  Color _getValidityColor() {
    if (item.isVencido) return AppTheme.error;
    if (item.isVencendoEm7Dias) return Colors.orange;
    return AppTheme.textSecondary;
  }
}