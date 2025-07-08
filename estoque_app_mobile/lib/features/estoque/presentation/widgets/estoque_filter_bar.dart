import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EstoqueFilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String?, bool, bool) onFilterChanged;

  const EstoqueFilterBar({
    super.key,
    required this.searchController,
    required this.onFilterChanged,
  });

  @override
  State<EstoqueFilterBar> createState() => _EstoqueFilterBarState();
}

class _EstoqueFilterBarState extends State<EstoqueFilterBar> {
  bool _apenasVencidos = false;
  bool _apenasBaixoEstoque = false;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onFilterChanged(
      widget.searchController.text.isNotEmpty 
          ? widget.searchController.text 
          : null,
      _apenasVencidos,
      _apenasBaixoEstoque,
    );
  }

  void _onFilterToggled() {
    widget.onFilterChanged(
      widget.searchController.text.isNotEmpty 
          ? widget.searchController.text 
          : null,
      _apenasVencidos,
      _apenasBaixoEstoque,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de busca
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar produtos...',
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
              fillColor: AppTheme.surface,
              filled: true,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Filtros
        Row(
          children: [
            _buildFilterChip(
              'Vencidos',
              _apenasVencidos,
              Icons.dangerous_outlined,
              AppTheme.error,
              (value) {
                setState(() {
                  _apenasVencidos = value;
                });
                _onFilterToggled();
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Baixo Estoque',
              _apenasBaixoEstoque,
              Icons.inventory_outlined,
              AppTheme.warning,
              (value) {
                setState(() {
                  _apenasBaixoEstoque = value;
                });
                _onFilterToggled();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    IconData icon,
    Color color,
    Function(bool) onChanged,
  ) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: onChanged,
      selectedColor: color,
      backgroundColor: Colors.transparent,
      side: BorderSide(color: color),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
} 