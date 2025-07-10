import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_event.dart';
import '../../data/services/estoque_service.dart';
import '../../data/models/estoque_item.dart';

class AddItemDialog extends StatefulWidget {
  final int despensaId;

  const AddItemDialog({super.key, required this.despensaId});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _observacoesController = TextEditingController();

  DateTime? _dataValidade;
  String _unidadeMedida = 'unidades';

  static const List<String> _unidadesMedida = [
    'unidades',
    'kg',
    'gramas',
    'litros',
    'ml',
    'caixas',
    'pacotes',
    'latas',
    'frascos',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nome do produto
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  hintText: 'Ex: Arroz branco',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Quantidade e unidade
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        hintText: '0',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Quantidade é obrigatória';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Quantidade inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _unidadeMedida,
                      decoration: const InputDecoration(labelText: 'Unidade'),
                      items: _unidadesMedida.map((unidade) {
                        return DropdownMenuItem(
                          value: unidade,
                          child: Text(unidade),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _unidadeMedida = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Data de validade
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de Validade (opcional)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dataValidade != null
                        ? '${_dataValidade!.day}/${_dataValidade!.month}/${_dataValidade!.year}'
                        : 'Selecionar data',
                    style: TextStyle(
                      color: _dataValidade != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Observações
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  hintText: 'Ex: Comprado no supermercado X',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _addItem, child: const Text('Adicionar')),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _dataValidade = picked;
      });
    }
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      // TODO: Primeiro criar o produto se não existir
      // Por enquanto, vamos usar um produto fictício
      final request = AdicionarEstoqueDto(
        despensaId: widget.despensaId,
        nomeProduto: _nomeController.text,
        quantidade: int.parse(_quantidadeController.text),
        quantidadeMinima: 1,
        dataValidade: _dataValidade,
      );

      context.read<EstoqueBloc>().add(AddItemToEstoque(request));
      Navigator.of(context).pop();
    }
  }
}
