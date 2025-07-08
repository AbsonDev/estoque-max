import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_event.dart';
import '../bloc/estoque_state.dart';
import '../widgets/estoque_item_card.dart';
import '../widgets/estoque_stats_card.dart';
import '../widgets/estoque_filter_bar.dart';
import '../widgets/adicionar_item_dialog.dart';
import '../widgets/consumir_item_dialog.dart';
import '../widgets/editar_item_dialog.dart';
import '../../data/models/estoque_item.dart';

class EstoqueScreen extends StatefulWidget {
  final int? despensaId;
  final String? despensaNome;

  const EstoqueScreen({
    super.key,
    this.despensaId,
    this.despensaNome,
  });

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarEstoque();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _carregarEstoque() {
    context.read<EstoqueBloc>().add(CarregarEstoque(despensaId: widget.despensaId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estoque',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            if (widget.despensaNome != null)
              Text(
                widget.despensaNome!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
            onPressed: _carregarEstoque,
          ),
        ],
      ),
      body: BlocConsumer<EstoqueBloc, EstoqueState>(
        listener: (context, state) {
          if (state is EstoqueError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          } else if (state is EstoqueOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EstoqueLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            );
          }

          if (state is EstoqueError) {
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _carregarEstoque,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is EstoqueLoaded) {
            return _buildEstoqueLoaded(state);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdicionarItemDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEstoqueLoaded(EstoqueLoaded state) {
    return RefreshIndicator(
      onRefresh: () async => _carregarEstoque(),
      child: CustomScrollView(
        slivers: [
          // Estatísticas
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: EstoqueStatsCard(state: state),
            ),
          ),

          // Barra de filtros
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EstoqueFilterBar(
                searchController: _searchController,
                onFilterChanged: (filtro, vencidos, baixoEstoque) {
                  context.read<EstoqueBloc>().add(FiltrarEstoque(
                    filtro: filtro,
                    apenasVencidos: vencidos,
                    apenasBaixoEstoque: baixoEstoque,
                  ));
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Lista de itens
          if (state.itensFiltrados.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(state),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = state.itensFiltrados[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: index == state.itensFiltrados.length - 1 ? 100 : 8,
                    ),
                    child: EstoqueItemCard(
                      item: item,
                      onTap: () => _showItemDetails(context, item),
                      onConsumirPressed: () => _showConsumir(context, item),
                      onEditPressed: () => _showEditarItem(context, item),
                      onDeletePressed: () => _showDeleteConfirmation(context, item),
                    ),
                  );
                },
                childCount: state.itensFiltrados.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(EstoqueLoaded state) {
    String titulo;
    String subtitulo;
    IconData icone;

    if (state.filtroAtual?.isNotEmpty == true ||
        state.apenasVencidos ||
        state.apenasBaixoEstoque) {
      titulo = 'Nenhum item encontrado';
      subtitulo = 'Tente alterar os filtros aplicados';
      icone = Icons.search_off;
    } else {
      titulo = 'Estoque vazio';
      subtitulo = 'Adicione seus primeiros itens ao estoque';
      icone = Icons.inventory_2_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icone,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAdicionarItemDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Item'),
          ),
        ],
      ),
    );
  }

  void _showAdicionarItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AdicionarItemDialog(
        despensaId: widget.despensaId,
      ),
    );
  }

  void _showItemDetails(BuildContext context, EstoqueItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildItemDetailsSheet(context, item),
    );
  }

  Widget _buildItemDetailsSheet(BuildContext context, EstoqueItem item) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  item.produtoNome,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.produtoMarca != null)
                  Text(
                    item.produtoMarca!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),

                const SizedBox(height: 24),

                // Informações
                _buildDetailRow('Quantidade', '${item.quantidade}'),
                _buildDetailRow('Quantidade Mínima', '${item.quantidadeMinima}'),
                _buildDetailRow('Despensa', item.despensaNome),
                if (item.dataValidade != null)
                  _buildDetailRow(
                    'Data de Validade',
                    '${item.dataValidade!.day}/${item.dataValidade!.month}/${item.dataValidade!.year}',
                  ),
                if (item.produtoCodigoBarras != null)
                  _buildDetailRow('Código de Barras', item.produtoCodigoBarras!),

                const SizedBox(height: 24),

                // Alertas
                if (item.estaVencido)
                  _buildAlertChip(
                    'Vencido',
                    Icons.dangerous,
                    AppTheme.error,
                  ),
                if (item.venceEm7Dias && !item.estaVencido)
                  _buildAlertChip(
                    'Vence em 7 dias',
                    Icons.warning,
                    Colors.orange,
                  ),
                if (item.precisaRepor)
                  _buildAlertChip(
                    'Baixo estoque',
                    Icons.inventory_outlined,
                    AppTheme.warning,
                  ),

                const SizedBox(height: 24),

                // Ações
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showConsumir(context, item);
                        },
                        icon: const Icon(Icons.remove),
                        label: const Text('Consumir'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditarItem(context, item);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertChip(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showConsumir(BuildContext context, EstoqueItem item) {
    showDialog(
      context: context,
      builder: (context) => ConsumirItemDialog(item: item),
    );
  }

  void _showEditarItem(BuildContext context, EstoqueItem item) {
    showDialog(
      context: context,
      builder: (context) => EditarItemDialog(item: item),
    );
  }

  void _showDeleteConfirmation(BuildContext context, EstoqueItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja remover "${item.produtoNome}" do estoque?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EstoqueBloc>().add(RemoverItemEstoque(item.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
} 