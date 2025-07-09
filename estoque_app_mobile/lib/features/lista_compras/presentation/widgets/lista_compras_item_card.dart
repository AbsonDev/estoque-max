import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/lista_compras_models.dart';

class ListaComprasItemCard extends StatelessWidget {
  final ListaComprasItem item;
  final VoidCallback onToggleComprado;
  final VoidCallback onRemove;

  const ListaComprasItemCard({
    super.key,
    required this.item,
    required this.onToggleComprado,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onToggleComprado(),
            backgroundColor: item.comprado
                ? AppTheme.warning
                : AppTheme.success,
            foregroundColor: Colors.white,
            icon: item.comprado ? Icons.undo : Icons.check,
            label: item.comprado ? 'Desfazer' : 'Comprar',
          ),
          SlidableAction(
            onPressed: (_) => onRemove(),
            backgroundColor: AppTheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Remover',
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.comprado
                ? AppTheme.success.withOpacity(0.3)
                : AppTheme.primaryColor.withOpacity(0.1),
            width: 1,
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
            Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggleComprado,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.comprado
                          ? AppTheme.success
                          : Colors.transparent,
                      border: Border.all(
                        color: item.comprado
                            ? AppTheme.success
                            : AppTheme.textSecondary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: item.comprado
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),

                const SizedBox(width: 12),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nome,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: item.comprado
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                          decoration: item.comprado
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.categoria,
                              style: TextStyle(
                                color: _getCategoryColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item.tipo == TipoItem.sugestao)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.psychology,
                                    color: AppTheme.primaryColor,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'IA',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quantity and price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantidade}x',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: item.comprado
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(
                        locale: 'pt_BR',
                        symbol: 'R\$',
                      ).format(item.totalValue),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.comprado
                            ? AppTheme.textSecondary
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (item.observacoes != null && item.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.observacoes!,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (item.comprado && item.dataCompra != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, color: AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Comprado em ${DateFormat('dd/MM/yyyy HH:mm').format(item.dataCompra!)}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (item.categoria.toLowerCase()) {
      case 'bebidas':
        return const Color(0xFF3498DB);
      case 'carnes':
        return const Color(0xFFE74C3C);
      case 'laticínios':
        return const Color(0xFFF39C12);
      case 'frutas':
        return const Color(0xFF27AE60);
      case 'legumes':
        return const Color(0xFF2ECC71);
      case 'grãos':
        return const Color(0xFF8E44AD);
      case 'limpeza':
        return const Color(0xFF16A085);
      case 'higiene':
        return const Color(0xFF9B59B6);
      default:
        return AppTheme.primaryColor;
    }
  }
}
