import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_event.dart';
import '../bloc/estoque_state.dart';
import '../widgets/estoque_item_card.dart';
import '../widgets/estoque_stats_card.dart';
import '../widgets/estoque_filter_chips.dart';
import '../widgets/estoque_sort_dialog.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/estoque_empty_state.dart';
import '../widgets/estoque_loading_skeleton.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  int _selectedDespensaId = 1; // TODO: Implementar seleção de despensa
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Carrega o estoque inicial
    context.read<EstoqueBloc>().add(LoadEstoque(_selectedDespensaId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStats(),
            _buildFilters(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estoque',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gerencie seus itens',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Busca
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSearchExpanded ? 200 : 48,
            height: 48,
            child: _isSearchExpanded
                ? TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar itens...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _toggleSearch,
                      ),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // TODO: Implementar busca
                    },
                  )
                : IconButton(
                    onPressed: _toggleSearch,
                    icon: const Icon(Icons.search),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      foregroundColor: AppTheme.textPrimary,
                    ),
                  ),
          ),

          const SizedBox(width: 8),

          // Ordenação
          IconButton(
            onPressed: _showSortDialog,
            icon: const Icon(Icons.sort),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surface,
              foregroundColor: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return BlocBuilder<EstoqueBloc, EstoqueState>(
      builder: (context, state) {
        if (state is EstoqueLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EstoqueStatsCard(
              totalItems: state.totalItems,
              itensVencidos: state.itensVencidos,
              itensVencendo: state.itensVencendo,
              itensBaixoEstoque: state.itensBaixoEstoque,
              itensEmFalta: state.itensEmFalta,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilters() {
    return BlocBuilder<EstoqueBloc, EstoqueState>(
      builder: (context, state) {
        if (state is EstoqueLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: EstoqueFilterChips(
              currentFilter: state.currentFilter,
              onFilterChanged: (filter) {
                context.read<EstoqueBloc>().add(FilterEstoque(filter));
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent() {
    return BlocConsumer<EstoqueBloc, EstoqueState>(
      listener: (context, state) {
        if (state is EstoqueError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is EstoqueOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is EstoqueLoading) {
          return const EstoqueLoadingSkeleton();
        }

        if (state is EstoqueLoaded) {
          final items = state.filteredItems;

          if (items.isEmpty) {
            return EstoqueEmptyState(
              filter: state.currentFilter,
              onAddItem: _showAddItemDialog,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<EstoqueBloc>().add(
                RefreshEstoque(_selectedDespensaId),
              );
            },
            child: AnimationLimiter(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: EstoqueItemCard(
                          item: item,
                          onTap: () => _showItemDetails(item),
                          onEdit: () => _showEditItemDialog(item),
                          onConsume: () => _showConsumeItemDialog(item),
                          onDelete: () => _showDeleteConfirmDialog(item),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        if (state is EstoqueError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar estoque',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<EstoqueBloc>().add(
                      LoadEstoque(_selectedDespensaId),
                    );
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<EstoqueBloc, EstoqueState>(
      builder: (context, state) {
        if (state is EstoqueOperationInProgress) {
          return FloatingActionButton(
            onPressed: null,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.5),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        return FloatingActionButton(
          onPressed: _showAddItemDialog,
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ).animate().scale(duration: 300.ms);
      },
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
      }
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: context.read<EstoqueBloc>(),
        child: const EstoqueSortDialog(),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: context.read<EstoqueBloc>(),
        child: AddItemDialog(despensaId: _selectedDespensaId),
      ),
    );
  }

  void _showItemDetails(item) {
    // TODO: Implementar detalhes do item
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.produto),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quantidade: ${item.quantidade} ${item.produto.unidadeMedida}',
            ),
            if (item.dataValidade != null)
              Text(
                'Validade: ${item.dataValidade!.day}/${item.dataValidade!.month}/${item.dataValidade!.year}',
              ),
            if (item.observacoes != null)
              Text('Observações: ${item.observacoes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(item) {
    // TODO: Implementar edição
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Editar item - Em desenvolvimento'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConsumeItemDialog(item) {
    // TODO: Implementar consumo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consumir item - Em desenvolvimento'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteConfirmDialog(item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja remover "${item.produto}" do estoque?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<EstoqueBloc>().add(RemoveEstoqueItem(item.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
