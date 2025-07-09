import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_state.dart';
import '../bloc/estoque_event.dart';
import '../../data/models/estoque_item.dart';
import '../../data/services/estoque_service.dart';

class ConsumirItemDialog extends StatefulWidget {
  final EstoqueItem item;

  const ConsumirItemDialog({super.key, required this.item});

  @override
  State<ConsumirItemDialog> createState() => _ConsumirItemDialogState();
}

class _ConsumirItemDialogState extends State<ConsumirItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantidadeController.text = '1';
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EstoqueBloc, EstoqueState>(
      listener: (context, state) {
        if (state is EstoqueOperationSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.success,
            ),
          );
        } else if (state is EstoqueError) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.remove_circle_outline, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('Consumir Item'),
            ],
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações do produto
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.produto.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.item.produto.marca != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.item.produto.marca!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Estoque atual: ${widget.item.quantidade}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quantidade a consumir
                TextFormField(
                  controller: _quantidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade a Consumir',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.remove),
                    helperText: 'Quantidade que será removida do estoque',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    final quantidade = int.tryParse(value);
                    if (quantidade == null || quantidade <= 0) {
                      return 'Quantidade deve ser maior que zero';
                    }
                    if (quantidade > widget.item.quantidade) {
                      return 'Quantidade não pode ser maior que o estoque';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Previsão do estoque após consumo
                _buildPrevisaoEstoque(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _consumirItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Consumir'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrevisaoEstoque() {
    final quantidadeConsumida = int.tryParse(_quantidadeController.text) ?? 0;
    final estoqueRestante = widget.item.quantidade - quantidadeConsumida;

    Color cor = AppTheme.success;
    IconData icone = Icons.check_circle_outline;
    String status = 'Estoque normal';

    if (estoqueRestante <= 0) {
      cor = AppTheme.error;
      icone = Icons.dangerous_outlined;
      status = 'Estoque zerado';
    } else if (estoqueRestante <= widget.item.quantidadeMinima) {
      cor = AppTheme.warning;
      icone = Icons.warning_outlined;
      status = 'Baixo estoque';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estoque após consumo: $estoqueRestante',
                  style: TextStyle(fontWeight: FontWeight.bold, color: cor),
                ),
                Text(status, style: TextStyle(fontSize: 12, color: cor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _consumirItem() {
    if (_formKey.currentState!.validate()) {
      final request = ConsumirItemRequest(
        quantidadeConsumida: double.parse(_quantidadeController.text),
        observacoes: null,
      );

      context.read<EstoqueBloc>().add(
        ConsumeEstoqueItem(widget.item.id, request),
      );
    }
  }
}
