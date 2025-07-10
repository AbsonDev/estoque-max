import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/produto.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_event.dart';
import '../bloc/estoque_state.dart';

class ProdutoAutocompleteField extends StatefulWidget {
  final Function(Produto?) onProdutoSelected;
  final Function(String) onNomeProdutoChanged;
  final String? initialValue;
  final String? label;

  const ProdutoAutocompleteField({
    super.key,
    required this.onProdutoSelected,
    required this.onNomeProdutoChanged,
    this.initialValue,
    this.label,
  });

  @override
  State<ProdutoAutocompleteField> createState() => _ProdutoAutocompleteFieldState();
}

class _ProdutoAutocompleteFieldState extends State<ProdutoAutocompleteField> {
  final _controller = TextEditingController();
  List<Produto> _produtos = [];
  Produto? _produtoSelecionado;
  Timer? _debounceTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<List<Produto>> _searchProdutos(String query) async {
    if (query.isEmpty) return [];
    
    setState(() {
      _isLoading = true;
    });

    final completer = Completer<List<Produto>>();
    
    // Listen for a single response
    StreamSubscription? subscription;
    subscription = context.read<EstoqueBloc>().stream.listen((state) {
      if (state is ProdutosLoaded && state.query == query) {
        subscription?.cancel();
        setState(() {
          _isLoading = false;
        });
        completer.complete(state.produtos);
      } else if (state is ProdutosError) {
        subscription?.cancel();
        setState(() {
          _isLoading = false;
        });
        completer.complete([]);
      }
    });

    // Dispatch the search
    context.read<EstoqueBloc>().add(SearchProdutos(query));

    // Timeout after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        subscription?.cancel();
        setState(() {
          _isLoading = false;
        });
        completer.complete([]);
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<Produto>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            final query = textEditingValue.text.trim();
            
            // Notificar mudança do nome
            widget.onNomeProdutoChanged(query);
            
            if (query.isEmpty) {
              return const Iterable<Produto>.empty();
            }

            // Debounce para evitar muitas chamadas
            _debounceTimer?.cancel();
            final completer = Completer<Iterable<Produto>>();
            
            _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
              try {
                final produtos = await _searchProdutos(query);
                setState(() {
                  _produtos = produtos;
                });
                completer.complete(produtos);
              } catch (e) {
                completer.complete(const Iterable<Produto>.empty());
              }
            });

            return completer.future;
          },
          displayStringForOption: (Produto produto) => produto.nome,
          onSelected: (Produto produto) {
            setState(() {
              _produtoSelecionado = produto;
            });
            widget.onProdutoSelected(produto);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Sincronizar com nosso controller
            if (controller.text != _controller.text) {
              _controller.text = controller.text;
            }
            
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label ?? 'Nome do Produto',
                hintText: 'Digite o nome do produto...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_produtoSelecionado != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          setState(() {
                            _produtoSelecionado = null;
                          });
                          widget.onProdutoSelected(null);
                          widget.onNomeProdutoChanged('');
                        },
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(Icons.search),
                      ),
                  ],
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o nome do produto';
                }
                return null;
              },
              onChanged: (value) {
                // Limpar produto selecionado se o texto for diferente
                if (_produtoSelecionado != null && _produtoSelecionado!.nome != value) {
                  setState(() {
                    _produtoSelecionado = null;
                  });
                  widget.onProdutoSelected(null);
                }
                widget.onNomeProdutoChanged(value);
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final produto = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(produto),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: index < options.length - 1
                                ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Ícone de categoria
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    produto.iconeCategoria,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Informações do produto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      produto.nome,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (produto.marca != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        produto.marca!,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                    if (produto.categoria != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        produto.categoriaFormatada,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              // Indicador de visibilidade
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: produto.visibilidade == TipoVisibilidadeProduto.publico
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  produto.visibilidade == TipoVisibilidadeProduto.publico ? 'Público' : 'Privado',
                                  style: TextStyle(
                                    color: produto.visibilidade == TipoVisibilidadeProduto.publico
                                        ? Colors.green.shade700
                                        : Colors.blue.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 8),
        
        // Indicador de produto novo vs existente
        if (_controller.text.isNotEmpty && _produtoSelecionado == null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produto "${_controller.text}" será criado',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Um novo produto privado será adicionado automaticamente',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
        // Produto selecionado
        if (_produtoSelecionado != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produto "${_produtoSelecionado!.nome}" selecionado',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (_produtoSelecionado!.marca != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Marca: ${_produtoSelecionado!.marca}',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}