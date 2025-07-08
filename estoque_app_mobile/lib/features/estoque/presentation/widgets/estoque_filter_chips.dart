import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class EstoqueFilterChips extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;

  const EstoqueFilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  static const List<FilterOption> _filterOptions = [
    FilterOption(
      key: 'todos',
      label: 'Todos',
      icon: Icons.inventory_2,
      color: AppTheme.primaryColor,
    ),
    FilterOption(
      key: 'vencidos',
      label: 'Vencidos',
      icon: Icons.warning,
      color: AppTheme.error,
    ),
    FilterOption(
      key: 'vencendo',
      label: 'Vencendo',
      icon: Icons.schedule,
      color: Colors.orange,
    ),
    FilterOption(
      key: 'baixo_estoque',
      label: 'Baixo Estoque',
      icon: Icons.trending_down,
      color: AppTheme.warning,
    ),
    FilterOption(
      key: 'em_falta',
      label: 'Em Falta',
      icon: Icons.remove_circle,
      color: AppTheme.error,
    ),
    FilterOption(
      key: 'precisa_comprar',
      label: 'Precisa Comprar',
      icon: Icons.shopping_cart,
      color: AppTheme.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterOptions.map((option) {
          final isSelected = currentFilter == option.key;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFilterChanged(option.key);
                }
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option.icon,
                    size: 16,
                    color: isSelected ? Colors.white : option.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : option.color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              backgroundColor: isSelected
                  ? option.color
                  : option.color.withOpacity(0.1),
              selectedColor: option.color,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? option.color
                    : option.color.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ).animate().fadeIn(duration: 300.ms).scale(
              delay: Duration(milliseconds: _filterOptions.indexOf(option) * 100),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterOption {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const FilterOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
} 