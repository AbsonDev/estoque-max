import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/responsive/responsive_utils.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/web_layout.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_event.dart';
import '../bloc/estoque_state.dart';
import '../widgets/estoque_item_card.dart';
import '../widgets/estoque_stats_card.dart';
import '../widgets/estoque_filter_chips.dart';
import '../widgets/estoque_sort_dialog.dart';
import '../widgets/adicionar_item_dialog_improved.dart';
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
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Carrega todos os itens de estoque (de todas as despensas)
    context.read<EstoqueBloc>().add(const LoadTodosEstoqueItens());
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
    final isWebLayout = ResponsiveUtils.isWebLayout(context);
    
    if (isWebLayout) {
      return _buildWebLayout(context);
    }
    
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

  Widget _buildWebLayout(BuildContext context) {
    return WebPageLayout(
      title: 'Estoque Geral',
      subtitle: 'Gerencie todos os itens de todas as suas despensas',
      actions: [
        WebSearchBar(
          controller: _searchController,
          hintText: 'Buscar itens no estoque...',
          width: 280,
          height: 48,
          onChanged: (value) {
            // TODO: Implementar busca
          },
        ),
        const SizedBox(width: 12),
        WebActionButton(
          onPressed: _showSortDialog,
          icon: Icon(Icons.sort, size: 18),
          label: 'Ordenar',
          isPrimary: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        const SizedBox(width: 12),
        WebActionButton(
          onPressed: _showAddItemDialog,
          icon: Icon(Icons.add, size: 18),
          label: 'Adicionar',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<EstoqueBloc>().add(const RefreshTodosEstoqueItens());
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildWebStats(context),
              const SizedBox(height: 12),
              _buildWebFilters(context),
              const SizedBox(height: 12),
              _buildWebContent(context),
              const SizedBox(height: 20), // Espaçamento extra no final
            ],
          ),
        ),
      ),
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
                  'Estoque Geral',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Todos os itens de todas as despensas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
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
                      fillColor: AppColors.surface,
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
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
          ),

          const SizedBox(width: 8),

          // Ordenação
          IconButton(
            onPressed: _showSortDialog,
            icon: const Icon(Icons.sort),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
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
              context.read<EstoqueBloc>().add(const RefreshTodosEstoqueItens());
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
                      const LoadTodosEstoqueItens(),
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
        child: const AdicionarItemDialogImproved(),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  // Métodos específicos para layout web

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estoque Geral',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: ResponsiveUtils.getFontSize(context, 32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gerencie todos os itens de todas as suas despensas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: ResponsiveUtils.getFontSize(context, 18),
                  ),
                ),
              ],
            ),
          ),

          // Busca e ações para web
          Row(
            children: [
              Container(
                width: 350,
                height: 56,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar itens no estoque...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    // TODO: Implementar busca
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _showSortDialog,
                  icon: Icon(Icons.sort, color: AppColors.textPrimary),
                  label: Text('Ordenar', style: TextStyle(color: AppColors.textPrimary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebStats(BuildContext context) {
    return BlocBuilder<EstoqueBloc, EstoqueState>(
      builder: (context, state) {
        if (state is EstoqueLoaded) {
          return Container(
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

  Widget _buildWebFilters(BuildContext context) {
    return BlocBuilder<EstoqueBloc, EstoqueState>(
      builder: (context, state) {
        if (state is EstoqueLoaded) {
          return Container(
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

  Widget _buildWebContent(BuildContext context) {
    return BlocConsumer<EstoqueBloc, EstoqueState>(
      listener: (context, state) {
        if (state is EstoqueError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is EstoqueOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
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

          final columns = ResponsiveUtils.getGridColumnsForCards(context);
          final spacing = ResponsiveUtils.getCompactSpacing(context);

          return AnimationLimiter(
            child: WebGrid(
              crossAxisCount: columns,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: columns,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: EstoqueItemCard(
                        item: item,
                        onEdit: () => _showEditItemDialog(item),
                        onConsume: () => _showConsumeItemDialog(item),
                        onDelete: () => _showDeleteConfirmDialog(item),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }

        if (state is EstoqueError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar estoque',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<EstoqueBloc>().add(
                      const LoadTodosEstoqueItens(),
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
}
