import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/despensa.dart';

class DespensaCard extends StatelessWidget {
  final Despensa despensa;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onInvite;
  final bool isLoading;

  const DespensaCard({
    super.key,
    required this.despensa,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onInvite,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.surface,
                AppTheme.surface.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com ícone e menu
              Row(
                children: [
                  _buildIcon(),
                  const Spacer(),
                  if (!isLoading) _buildPopupMenu(context),
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Nome da despensa
              Text(
                despensa.nome,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Informações básicas
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: _buildInfoChip(
                            icon: Icons.inventory_2_outlined,
                            label: '${despensa.totalItens} itens',
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _buildInfoChip(
                            icon: Icons.people_outline,
                            label: '${despensa.totalMembros} membros',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Papel do usuário
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getRoleColor().withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      despensa.sounDono ? Icons.star : Icons.person_outline,
                      size: 14,
                      color: _getRoleColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      despensa.meuPapel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getRoleColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Data de criação
              Text(
                'Criada em ${_formatDate(despensa.dataCriacao)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        _getDespensaIcon(),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppTheme.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'invite':
            onInvite?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (despensa.possoEditar)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                const Text('Editar'),
              ],
            ),
          ),
        if (despensa.possoConvidar)
          PopupMenuItem(
            value: 'invite',
            child: Row(
              children: [
                Icon(Icons.person_add_outlined, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                const Text('Convidar membro'),
              ],
            ),
          ),
        if (despensa.possoDeletar)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: AppTheme.error),
                const SizedBox(width: 8),
                Text('Deletar', style: TextStyle(color: AppTheme.error)),
              ],
            ),
          ),
      ],
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
        color: color.withValues(alpha: 0.1),
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

  IconData _getDespensaIcon() {
    final nome = despensa.nome.toLowerCase();
    
    if (nome.contains('cozinha') || nome.contains('kitchen')) {
      return Icons.kitchen_outlined;
    } else if (nome.contains('banho') || nome.contains('bathroom') || nome.contains('casa de banho')) {
      return Icons.bathtub_outlined;
    } else if (nome.contains('lavandaria') || nome.contains('lavanderia') || nome.contains('laundry')) {
      return Icons.local_laundry_service_outlined;
    } else if (nome.contains('escritório') || nome.contains('office')) {
      return Icons.business_center_outlined;
    } else if (nome.contains('quarto') || nome.contains('bedroom')) {
      return Icons.bed_outlined;
    } else if (nome.contains('garagem') || nome.contains('garage')) {
      return Icons.garage_outlined;
    } else if (nome.contains('despensa') || nome.contains('pantry')) {
      return Icons.food_bank_outlined;
    }
    
    return Icons.home_outlined;
  }

  Color _getRoleColor() {
    return despensa.sounDono ? Colors.amber : AppTheme.primaryColor;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
} 