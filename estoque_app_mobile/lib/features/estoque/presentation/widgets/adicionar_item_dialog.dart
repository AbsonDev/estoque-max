import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_event.dart';
import '../bloc/estoque_state.dart';
import '../../data/models/estoque_item.dart';
import '../../data/models/produto.dart';
import '../../data/services/estoque_service.dart';

class AdicionarItemDialog extends StatefulWidget {
  final int? despensaId;

  const AdicionarItemDialog({super.key, this.despensaId});

  @override
  State<AdicionarItemDialog> createState() => _AdicionarItemDialogState();
}

class _AdicionarItemDialogState extends State<AdicionarItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _quantidadeMinimaController = TextEditingController(text: '1');
  final _codigoBarrasController = TextEditingController();

  Produto? _produtoSelecionado;
  DateTime? _dataValidade;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<EstoqueBloc>().add(const SearchProdutos(''));
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _quantidadeMinimaController.dispose();
    _codigoBarrasController.dispose();
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
          title: const Text('Adicionar Item'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Busca por código de barras
                  _buildCodigoBarrasField(),
                  const SizedBox(height: 16),

                  // Seleção de produto
                  _buildProdutoSelector(state),
                  const SizedBox(height: 16),

                  // Quantidade
                  TextFormField(
                    controller: _quantidadeController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.numbers),
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quantidade mínima
                  TextFormField(
                    controller: _quantidadeMinimaController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade Mínima',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.warning_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      final quantidade = int.tryParse(value);
                      if (quantidade == null || quantidade < 0) {
                        return 'Quantidade deve ser maior ou igual a zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Data de validade
                  _buildDataValidadeField(),
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
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCodigoBarrasField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _codigoBarrasController,
            decoration: const InputDecoration(
              labelText: 'Código de Barras',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.qr_code_scanner),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _buscarProdutoPorCodigoBarras,
          icon: const Icon(Icons.search),
          tooltip: 'Buscar produto',
        ),
      ],
    );
  }

  Widget _buildProdutoSelector(EstoqueState state) {
    if (state is EstoqueLoaded) {
      return DropdownButtonFormField<Produto>(
        value: _produtoSelecionado,
        decoration: const InputDecoration(
          labelText: 'Produto',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.inventory_2_outlined),
        ),
        items: state.produtos.map((produto) {
          return DropdownMenuItem(
            value: produto,
            child: Text(
              produto.marca != null
                  ? '${produto.nome} - ${produto.marca}'
                  : produto.nome,
            ),
          );
        }).toList(),
        onChanged: (produto) {
          setState(() {
            _produtoSelecionado = produto;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Selecione um produto';
          }
          return null;
        },
      );
    }

    return const CircularProgressIndicator();
  }

  Widget _buildDataValidadeField() {
    return InkWell(
      onTap: _selecionarDataValidade,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data de Validade (opcional)',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_month_outlined),
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
    );
  }

  void _buscarProdutoPorCodigoBarras() {
    final codigoBarras = _codigoBarrasController.text.trim();
    if (codigoBarras.isNotEmpty) {
      context.read<EstoqueBloc>().add(SearchProdutos(codigoBarras));
    }
  }

  Future<void> _selecionarDataValidade() async {
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataValidade = dataEscolhida;
      });
    }
  }

  void _salvarItem() {
    if (_formKey.currentState!.validate()) {
      if (widget.despensaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Despensa não especificada'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final request = AdicionarEstoqueDto(
        despensaId: widget.despensaId!,
        produtoId: _produtoSelecionado?.id,
        quantidade: int.parse(_quantidadeController.text),
        quantidadeMinima: int.parse(_quantidadeMinimaController.text),
        dataValidade: _dataValidade,
      );

      context.read<EstoqueBloc>().add(AddItemToEstoque(request));
    }
  }
}
