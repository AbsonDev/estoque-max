import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_event.dart';
import '../bloc/estoque_state.dart';

class EstoqueSortDialog extends StatefulWidget {
  const EstoqueSortDialog({super.key});

  @override
  State<EstoqueSortDialog> createState() => _EstoqueSortDialogState();
}

class _EstoqueSortDialogState extends State<EstoqueSortDialog> {
  String _selectedSort = 'nome';
  bool _ascending = true;

  static const List<SortOption> _sortOptions = [
    SortOption(key: 'nome', label: 'Nome', icon: Icons.sort_by_alpha),
    SortOption(key: 'quantidade', label: 'Quantidade', icon: Icons.format_list_numbered),
    SortOption(key: 'validade', label: 'Validade', icon: Icons.schedule),
    SortOption(key: 'categoria', label: 'Categoria', icon: Icons.category),
    SortOption(key: 'status', label: 'Status', icon: Icons.flag),
    SortOption(key: 'data_adicao', label: 'Data de Adição', icon: Icons.date_range),
  ];

  @override
  void initState() {
    super.initState();
    
    // Obtém a ordenação atual
    final state = context.read<EstoqueBloc>().state;
    if (state is EstoqueLoaded) {
      _selectedSort = state.currentSort;
      _ascending = state.sortAscending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ordenar por'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opções de ordenação
          ..._sortOptions.map((option) => RadioListTile<String>(
            value: option.key,
            groupValue: _selectedSort,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSort = value;
                });
              }
            },
            title: Row(
              children: [
                Icon(option.icon, size: 20),
                const SizedBox(width: 8),
                Text(option.label),
              ],
            ),
            dense: true,
          )),
          
          const Divider(),
          
          // Direção da ordenação
          SwitchListTile(
            value: _ascending,
            onChanged: (value) {
              setState(() {
                _ascending = value;
              });
            },
            title: Text(_ascending ? 'Crescente' : 'Decrescente'),
            subtitle: Text(_ascending ? 'A → Z' : 'Z → A'),
            secondary: Icon(
              _ascending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<EstoqueBloc>().add(SortEstoque(_selectedSort, _ascending));
            Navigator.of(context).pop();
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}

class SortOption {
  final String key;
  final String label;
  final IconData icon;

  const SortOption({
    required this.key,
    required this.label,
    required this.icon,
  });
} 