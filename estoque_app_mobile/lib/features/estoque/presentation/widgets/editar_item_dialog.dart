import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/estoque_item.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_event.dart';
import '../bloc/estoque_state.dart';

class EditarItemDialog extends StatefulWidget {
  final EstoqueItem item;
  final VoidCallback? onItemEditado;

  const EditarItemDialog({Key? key, required this.item, this.onItemEditado})
    : super(key: key);

  @override
  State<EditarItemDialog> createState() => _EditarItemDialogState();
}

class _EditarItemDialogState extends State<EditarItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantidadeController;
  late TextEditingController _quantidadeMinimaController;
  late TextEditingController _precoController;
  late TextEditingController _dataValidadeController;

  DateTime? _dataValidadeSelecionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantidadeController = TextEditingController(
      text: widget.item.quantidade.toString(),
    );
    _quantidadeMinimaController = TextEditingController(
      text: widget.item.quantidadeMinima.toString(),
    );
    _precoController = TextEditingController(
      text: '',
    ); // Remover referência ao preço
    _dataValidadeSelecionada = widget.item.dataValidade;
    _dataValidadeController = TextEditingController(
      text: _dataValidadeSelecionada != null
          ? DateFormat('dd/MM/yyyy').format(_dataValidadeSelecionada!)
          : '',
    );
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _quantidadeMinimaController.dispose();
    _precoController.dispose();
    _dataValidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EstoqueBloc, EstoqueState>(
      listener: (context, state) {
        if (state is EstoqueOperationSuccess) {
          setState(() => _isLoading = false);
          widget.onItemEditado?.call();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is EstoqueError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Editar Item'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Produto (não editável)
                TextFormField(
                  initialValue: widget.item.produto,
                  decoration: const InputDecoration(
                    labelText: 'Produto',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 16),

                // Despensa (não editável)
                TextFormField(
                  initialValue: widget.item.despensaNome,
                  decoration: const InputDecoration(
                    labelText: 'Despensa',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 16),

                // Quantidade
                TextFormField(
                  controller: _quantidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite a quantidade';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Digite um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quantidade Mínima
                TextFormField(
                  controller: _quantidadeMinimaController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade Mínima',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite a quantidade mínima';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Digite um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Preço
                TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(
                    labelText: 'Preço (opcional)',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Digite um preço válido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Data de Validade
                TextFormField(
                  controller: _dataValidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Validade (opcional)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _selecionarDataValidade,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _salvarItem,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarDataValidade() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataValidadeSelecionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _dataValidadeSelecionada = picked;
        _dataValidadeController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _salvarItem() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final request = AtualizarEstoqueDto(
        quantidade: int.parse(_quantidadeController.text),
        quantidadeMinima: int.parse(_quantidadeMinimaController.text),
        dataValidade: _dataValidadeSelecionada,
      );

      context.read<EstoqueBloc>().add(
        UpdateEstoqueItem(widget.item.id, request),
      );
    }
  }
}
