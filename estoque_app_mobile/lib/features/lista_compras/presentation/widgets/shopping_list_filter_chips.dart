import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ShoppingListFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const ShoppingListFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('all', 'Todos', Icons.list),
          const SizedBox(width: 12),
          _buildFilterChip('pending', 'Pendentes', Icons.pending_actions),
          const SizedBox(width: 12),
          _buildFilterChip('completed', 'Comprados', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = selectedFilter == value;
    
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(value);
        }
      },
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppTheme.textSecondary,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      backgroundColor: AppTheme.surface,
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.2),
        width: 1,
      ),
    );
  }
} 