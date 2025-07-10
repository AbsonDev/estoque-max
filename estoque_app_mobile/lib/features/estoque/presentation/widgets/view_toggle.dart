import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum ViewMode { list, grid }

class ViewToggle extends StatelessWidget {
  final ViewMode currentMode;
  final Function(ViewMode) onModeChanged;

  const ViewToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context,
            mode: ViewMode.list,
            icon: Icons.view_list,
            label: 'Lista',
          ),
          _buildToggleButton(
            context,
            mode: ViewMode.grid,
            icon: Icons.grid_view,
            label: 'Grid',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required ViewMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentMode == mode;
    
    return InkWell(
      onTap: () => onModeChanged(mode),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}