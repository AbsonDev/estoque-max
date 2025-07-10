import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_event.dart';
import '../bloc/estoque_state.dart';
import '../../data/models/estoque_item.dart';
import '../../data/models/produto.dart';
import '../../../despensas/data/models/despensa.dart';
import 'produto_autocomplete_field.dart';
import 'despensa_selector.dart';

class AdicionarItemDialogImproved extends StatefulWidget {
  final int? despensaId;

  const AdicionarItemDialogImproved({super.key, this.despensaId});

  @override
  State<AdicionarItemDialogImproved> createState() =>
      _AdicionarItemDialogImprovedState();
}

class _AdicionarItemDialogImprovedState
    extends State<AdicionarItemDialogImproved> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _quantidadeMinimaController = TextEditingController(text: '1');

  Produto? _produtoSelecionado;
  String? _nomeProdutoDigitado;
  Despensa? _despensaSelecionada;
  DateTime? _dataValidade;
  bool _isLoading = false;
  List<Despensa> _despensas = [];

  @override
  void initState() {
    super.initState();
    _carregarDespensas();
  }

  void _carregarDespensas() {
    // Usar o BLoC para carregar despensas
    context.read<EstoqueBloc>().add(const LoadDespensas());
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _quantidadeMinimaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener apenas para operações (success/error)
        BlocListener<EstoqueBloc, EstoqueState>(
          listenWhen: (previous, current) => 
            current is EstoqueOperationSuccess || current is EstoqueError,
          listener: (context, state) {
            if (state is EstoqueOperationSuccess) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is EstoqueError) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
      child: Builder(
        builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adicionar ao Estoque',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Adicione um novo item ao seu estoque',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Conteúdo
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Seleção de Despensa
                          _buildSectionTitle('Onde adicionar?'),
                          const SizedBox(height: 8),
                          _buildDespensaField(),

                          const SizedBox(height: 20),

                          // Autocomplete de Produto
                          _buildSectionTitle('Qual produto?'),
                          const SizedBox(height: 8),
                          ProdutoAutocompleteField(
                            onProdutoSelected: (produto) {
                              setState(() {
                                _produtoSelecionado = produto;
                                _nomeProdutoDigitado = produto?.nome;
                              });
                            },
                            onNomeProdutoChanged: (nome) {
                              setState(() {
                                _nomeProdutoDigitado = nome;
                                if (_produtoSelecionado != null &&
                                    _produtoSelecionado!.nome != nome) {
                                  _produtoSelecionado = null;
                                }
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          // Quantidade
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Quantidade'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _quantidadeController,
                                      decoration: const InputDecoration(
                                        hintText: 'Ex: 5',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.numbers),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Obrigatório';
                                        }
                                        final quantidade = int.tryParse(value);
                                        if (quantidade == null ||
                                            quantidade <= 0) {
                                          return 'Deve ser > 0';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Mínima'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _quantidadeMinimaController,
                                      decoration: const InputDecoration(
                                        hintText: 'Ex: 1',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(
                                          Icons.warning_outlined,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Obrigatório';
                                        }
                                        final quantidade = int.tryParse(value);
                                        if (quantidade == null ||
                                            quantidade < 0) {
                                          return 'Deve ser ≥ 0';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Data de validade
                          _buildSectionTitle('Data de Validade (opcional)'),
                          const SizedBox(height: 8),
                          _buildDataValidadeField(),

                          const SizedBox(height: 24),

                          // Resumo
                          if (_nomeProdutoDigitado != null &&
                              _nomeProdutoDigitado!.isNotEmpty)
                            _buildResumo(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Botões
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _salvarItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Adicionar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildDespensaField() {
    return BlocSelector<EstoqueBloc, EstoqueState, EstoqueState>(
      selector: (state) {
        // Só retorna estados relacionados a despensas
        if (state is DespensasLoading || 
            state is DespensasLoaded || 
            state is DespensasError) {
          return state;
        }
        // Para outros estados, retorna o último estado conhecido de despensas
        return DespensasLoaded(_despensas);
      },
      builder: (context, state) {
        if (state is DespensasLoading) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Carregando despensas...'),
              ],
            ),
          );
        }

        if (state is DespensasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.error),
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.error.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: AppTheme.error, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erro ao carregar despensas: ${state.message}',
                    style: TextStyle(color: AppTheme.error),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _carregarDespensas();
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (state is DespensasLoaded) {
          // Atualizar lista local sem setState desnecessário
          if (_despensas != state.despensas) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _despensas = state.despensas;
              // Definir despensa inicial se não tiver uma selecionada
              if (_despensaSelecionada == null && _despensas.isNotEmpty) {
                if (widget.despensaId != null) {
                  _despensaSelecionada = _despensas.firstWhere(
                    (d) => d.id == widget.despensaId,
                    orElse: () => _despensas.first,
                  );
                } else {
                  _despensaSelecionada = _despensas.first;
                }
                setState(() {});
              }
            });
          }

          return DespensaSelector(
            despensas: _despensas,
            selectedDespensa: _despensaSelecionada,
            onDespensaChanged: (despensa) {
              setState(() {
                _despensaSelecionada = despensa;
              });
            },
          );
        }

        // Estado padrão
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Nenhuma despensa encontrada'),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildDataValidadeField() {
    return InkWell(
      onTap: _selecionarDataValidade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dataValidade != null
                    ? DateFormat('dd/MM/yyyy').format(_dataValidade!)
                    : 'Selecionar data de validade',
                style: TextStyle(
                  color: _dataValidade != null
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
            if (_dataValidade != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    _dataValidade = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Resumo',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildResumoItem(
            'Despensa',
            _despensaSelecionada?.nome ?? 'Não selecionada',
          ),
          _buildResumoItem('Produto', _nomeProdutoDigitado!),
          if (_quantidadeController.text.isNotEmpty)
            _buildResumoItem('Quantidade', _quantidadeController.text),
          if (_quantidadeMinimaController.text.isNotEmpty)
            _buildResumoItem(
              'Quantidade Mínima',
              _quantidadeMinimaController.text,
            ),
          if (_dataValidade != null)
            _buildResumoItem(
              'Validade',
              DateFormat('dd/MM/yyyy').format(_dataValidade!),
            ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarDataValidade() async {
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('pt', 'BR'),
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataValidade = dataEscolhida;
      });
    }
  }

  void _salvarItem() {
    if (_formKey.currentState!.validate()) {
      if (_despensaSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione uma despensa'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Criar DTO com produtoId ou nomeProduto
      final dto = AdicionarEstoqueDto(
        despensaId: _despensaSelecionada!.id,
        produtoId: _produtoSelecionado?.id,
        nomeProduto: _produtoSelecionado == null ? _nomeProdutoDigitado : null,
        quantidade: int.parse(_quantidadeController.text),
        quantidadeMinima: int.parse(_quantidadeMinimaController.text),
        dataValidade: _dataValidade,
      );

      context.read<EstoqueBloc>().add(AddItemToEstoque(dto));
    }
  }
}
