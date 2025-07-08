import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class EstoqueEmptyState extends StatelessWidget {
  final String filter;
  final VoidCallback onAddItem;

  const EstoqueEmptyState({
    super.key,
    required this.filter,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              _getEmptyIcon(),
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 24),
          
          // Título
          Text(
            _getEmptyTitle(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          
          const SizedBox(height: 8),
          
          // Descrição
          Text(
            _getEmptyDescription(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
          
          const SizedBox(height: 32),
          
          // Botão de ação
          if (filter == 'todos')
            ElevatedButton.icon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Primeiro Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (filter) {
      case 'vencidos':
        return Icons.warning_amber_outlined;
      case 'vencendo':
        return Icons.schedule_outlined;
      case 'baixo_estoque':
        return Icons.trending_down_outlined;
      case 'em_falta':
        return Icons.remove_circle_outline;
      case 'precisa_comprar':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String _getEmptyTitle() {
    switch (filter) {
      case 'vencidos':
        return 'Nenhum item vencido';
      case 'vencendo':
        return 'Nenhum item vencendo';
      case 'baixo_estoque':
        return 'Nenhum item com baixo estoque';
      case 'em_falta':
        return 'Nenhum item em falta';
      case 'precisa_comprar':
        return 'Nenhum item precisa ser comprado';
      default:
        return 'Estoque vazio';
    }
  }

  String _getEmptyDescription() {
    switch (filter) {
      case 'vencidos':
        return 'Ótimo! Não há itens vencidos no seu estoque.';
      case 'vencendo':
        return 'Perfeito! Nenhum item está próximo do vencimento.';
      case 'baixo_estoque':
        return 'Excelente! Todos os itens estão com quantidade adequada.';
      case 'em_falta':
        return 'Muito bem! Não há itens em falta no momento.';
      case 'precisa_comprar':
        return 'Tudo em ordem! Não há itens para comprar agora.';
      default:
        return 'Comece adicionando alguns itens ao seu estoque para começar a gerenciar seus produtos.';
    }
  }
} 