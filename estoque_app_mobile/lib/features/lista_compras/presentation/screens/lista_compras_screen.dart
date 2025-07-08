import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/lista_compras_models.dart';
import '../bloc/lista_compras_bloc.dart';
import '../widgets/lista_compras_item_card.dart';
import '../widgets/shopping_list_stats.dart';
import '../widgets/ai_suggestions_card.dart';
import '../widgets/add_manual_item_dialog.dart';
import '../widgets/shopping_list_filter_chips.dart';

class ListaComprasScreen extends StatefulWidget {
  const ListaComprasScreen({super.key});

  @override
  State<ListaComprasScreen> createState() => _ListaComprasScreenState();
}

class _ListaComprasScreenState extends State<ListaComprasScreen> {
  String _filterStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  void _loadShoppingList() {
    context.read<ListaComprasBloc>().add(LoadListaCompras());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: BlocConsumer<ListaComprasBloc, ListaComprasState>(
                listener: (context, state) {
                  if (state is ListaComprasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ListaComprasLoading) {
                    return _buildLoading();
                  }

                  if (state is ListaComprasLoaded) {
                    return _buildShoppingList(state.lista);
                  }

                  return _buildError();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lista de Compras',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Organize suas compras com IA',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showAddManualItemDialog();
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar itens...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppTheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return ShoppingListFilterChips(
      selectedFilter: _filterStatus,
      onFilterChanged: (filter) {
        setState(() {
          _filterStatus = filter;
        });
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar lista',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente novamente mais tarde',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadShoppingList,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingList(ListaComprasResponse lista) {
    List<ListaComprasItem> filteredItems = _filterItems(lista.itens);

    return RefreshIndicator(
      onRefresh: () async {
        _loadShoppingList();
      },
      child: CustomScrollView(
        slivers: [
          // Stats
          SliverToBoxAdapter(
            child: ShoppingListStats(
              totalItems: lista.itens.length,
              completedItems: lista.itens.where((item) => item.comprado).length,
              totalValue: lista.itens.fold(0.0, (sum, item) => sum + item.valor),
              spentValue: lista.itens.where((item) => item.comprado).fold(0.0, (sum, item) => sum + item.valor),
            ),
          ),

          // AI Suggestions
          if (lista.sugestoesPreditivas.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AISuggestionsCard(
                  suggestions: lista.sugestoesPreditivas,
                  onAcceptSuggestion: (estoqueItemId) {
                    context.read<ListaComprasBloc>().add(
                      AcceptAISuggestion(estoqueItemId: estoqueItemId),
                    );
                  },
                ),
              ),
            ),

          // Items List
          if (filteredItems.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredItems[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ListaComprasItemCard(
                              item: item,
                              onToggleComprado: () {
                                context.read<ListaComprasBloc>().add(
                                  ToggleItemComprado(itemId: item.id),
                                );
                              },
                              onRemove: () {
                                context.read<ListaComprasBloc>().add(
                                  RemoveItem(itemId: item.id),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: filteredItems.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Lista vazia',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Adicione itens manualmente ou aceite sugestões da IA',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            _showAddManualItemDialog();
          },
          icon: const Icon(Icons.add),
          label: const Text('Adicionar Item'),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  List<ListaComprasItem> _filterItems(List<ListaComprasItem> items) {
    List<ListaComprasItem> filtered = items;

    // Filter by status
    if (_filterStatus != 'all') {
      filtered = filtered.where((item) {
        switch (_filterStatus) {
          case 'pending':
            return !item.comprado;
          case 'completed':
            return item.comprado;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.categoria.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  void _showAddManualItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddManualItemDialog(
        onAdd: (nome, categoria, quantidade, valor) {
          context.read<ListaComprasBloc>().add(
            AddManualItem(
              nome: nome,
              categoria: categoria,
              quantidade: quantidade,
              valor: valor,
            ),
          );
        },
      ),
    );
  }
} 