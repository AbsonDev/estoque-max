import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/despensas_bloc.dart';
import '../bloc/despensas_event.dart';
import '../bloc/despensas_state.dart';
import '../../data/models/despensa.dart';
import '../widgets/despensa_card.dart';
import '../widgets/criar_despensa_dialog.dart';
import '../widgets/editar_despensa_dialog.dart';
import '../widgets/convidar_membro_dialog.dart';
import '../widgets/empty_despensas_widget.dart';
import '../widgets/upgrade_required_widget.dart';
import '../../../../core/theme/app_theme.dart';

class DespensasScreen extends StatefulWidget {
  const DespensasScreen({super.key});

  @override
  State<DespensasScreen> createState() => _DespensasScreenState();
}

class _DespensasScreenState extends State<DespensasScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todas';
  bool _isSearchExpanded = false;

  final List<String> _filtros = [
    'Todas',
    'Proprietário',
    'Membro',
    'Cozinha',
    'Despensa',
    'Geladeira',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    context.read<DespensasBloc>().add(const LoadDespensas());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Despensa> _filtrarDespensas(List<Despensa> despensas) {
    List<Despensa> filtradas = despensas;

    // Aplica filtro de pesquisa
    if (_searchQuery.isNotEmpty) {
      filtradas = filtradas.where((despensa) {
        return despensa.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               despensa.meuPapel.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Aplica filtro de categoria
    if (_selectedFilter != 'Todas') {
      filtradas = filtradas.where((despensa) {
        switch (_selectedFilter) {
          case 'Proprietário':
            return despensa.sounDono;
          case 'Membro':
            return !despensa.sounDono;
          case 'Cozinha':
            return despensa.nome.toLowerCase().contains('cozinha');
          case 'Despensa':
            return despensa.nome.toLowerCase().contains('despensa');
          case 'Geladeira':
            return despensa.nome.toLowerCase().contains('geladeira');
          case 'Outros':
            return !['Cozinha', 'Despensa', 'Geladeira'].any(
              (tipo) => despensa.nome.toLowerCase().contains(tipo.toLowerCase())
            );
          default:
            return true;
        }
      }).toList();
    }

    return filtradas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchExpanded
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar despensas...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                autofocus: true,
              )
            : const Text('Minhas Despensas'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
                if (!_isSearchExpanded) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filtros.map((filtro) {
              return PopupMenuItem(
                value: filtro,
                child: Row(
                  children: [
                    Icon(
                      _selectedFilter == filtro
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: _selectedFilter == filtro
                          ? AppTheme.primaryColor
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(filtro),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de filtro ativo
          if (_selectedFilter != 'Todas' || _searchQuery.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtros ativos: ${_selectedFilter != 'Todas' ? _selectedFilter : ''}'
                      '${_searchQuery.isNotEmpty ? ' • "${_searchQuery}"' : ''}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'Todas';
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          
          // Conteúdo principal
          Expanded(
            child: BlocConsumer<DespensasBloc, DespensasState>(
              listener: _handleStateChanges,
              builder: (context, state) {
                final despensas = _filtrarDespensas(_getDespensas(state));
                return _buildContent(context, state, despensas);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildContent(BuildContext context, DespensasState state, List<Despensa> despensas) {
    if (state is DespensasLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DespensasEmpty) {
      return const EmptyDespensasWidget();
    }

    if (state is DespensasError && (state.despensas == null || state.despensas!.isEmpty)) {
      return _buildErrorState(context, state);
    }

    // Verifica se não há resultados após filtros
    if (despensas.isEmpty && (_searchQuery.isNotEmpty || _selectedFilter != 'Todas')) {
      return _buildNoResultsState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DespensasBloc>().add(const RefreshDespensas());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Estatísticas rápidas
            _buildQuickStats(despensas),
            
            // Grid de despensas
            _buildDespensasGrid(context, despensas, state, _isWideScreen(context), false),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(List<Despensa> despensas) {
    final totalItens = despensas.fold<int>(0, (sum, d) => sum + d.totalItens);
    final totalMembros = despensas.fold<int>(0, (sum, d) => sum + d.totalMembros);
    final minhasDespensas = despensas.where((d) => d.sounDono).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.storage,
            value: despensas.length.toString(),
            label: 'Despensas',
            color: AppTheme.primaryColor,
          ),
          _buildStatItem(
            icon: Icons.inventory,
            value: totalItens.toString(),
            label: 'Itens',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.people,
            value: totalMembros.toString(),
            label: 'Membros',
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.star,
            value: minhasDespensas.toString(),
            label: 'Minhas',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma despensa encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou pesquisar por outros termos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = 'Todas';
                _searchQuery = '';
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpar Filtros'),
          ),
        ],
      ),
    );
  }

  bool _isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  Widget _buildHeader(
    BuildContext context,
    DespensasState state,
    bool isWideScreen,
    bool isTablet,
  ) {
    final padding = isWideScreen ? 40.0 : (isTablet ? 32.0 : 24.0);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryVariant.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isWideScreen ? 60 : 50,
            height: isWideScreen ? 60 : 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryVariant],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isWideScreen ? 15 : 12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.home_work_rounded,
              color: Colors.white,
              size: isWideScreen ? 30 : 24,
            ),
          ),
          SizedBox(width: isWideScreen ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minhas Despensas',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    fontSize: isWideScreen ? 32 : (isTablet ? 28 : 24),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSubtitle(state),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: isWideScreen ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
          if (state is DespensasLoaded && state.despensas.isNotEmpty)
            _buildRefreshButton(context, state),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DespensasState state,
    bool isWideScreen,
    bool isTablet,
  ) {
    final padding = isWideScreen ? 40.0 : (isTablet ? 32.0 : 24.0);
    
    if (state is DespensasLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is DespensasEmpty) {
      return EmptyDespensasWidget(
        onCreateDespensa: () => _showCreateDespensaDialog(context),
        isLoading: state is DespensaOperationLoading,
      );
    }

    if (state is DespensasError && 
        (state.despensas == null || state.despensas!.isEmpty)) {
      return _buildErrorWidget(context, state.message);
    }

    // Estados com dados
    final despensas = _getDespensas(state);
    if (despensas.isEmpty) {
      return EmptyDespensasWidget(
        onCreateDespensa: () => _showCreateDespensaDialog(context),
        isLoading: state is DespensaOperationLoading,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DespensasBloc>().add(const RefreshDespensas());
        // Aguarda um pouco para dar feedback visual
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loading indicator para refresh
            if (state is DespensasRefreshing)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),

            // Grid de despensas
            _buildDespensasGrid(context, despensas, state, isWideScreen, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildDespensasGrid(
    BuildContext context,
    List<Despensa> despensas,
    DespensasState state,
    bool isWideScreen,
    bool isTablet,
  ) {
    int crossAxisCount;
    double childAspectRatio;
    
    if (isWideScreen) {
      crossAxisCount = 4;
      childAspectRatio = 0.85;
    } else if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 0.8;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.75;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: isWideScreen ? 20 : 16,
        mainAxisSpacing: isWideScreen ? 20 : 16,
      ),
      itemCount: despensas.length,
      itemBuilder: (context, index) {
        final despensa = despensas[index];
        return DespensaCard(
          despensa: despensa,
          onTap: () => _navigateToDespensaDetalhes(context, despensa.id),
          onEdit: despensa.possoEditar
              ? () => _showEditDespensaDialog(context, despensa)
              : null,
          onDelete: despensa.possoDeletar
              ? () => _showDeleteConfirmation(context, despensa)
              : null,
          onInvite: despensa.possoConvidar
              ? () => _showInviteMemberDialog(context, despensa.id)
              : null,
          isLoading: state is DespensaOperationLoading &&
              state.despensaId == despensa.id,
        );
      },
    );
  }

  Widget _buildRefreshButton(BuildContext context, DespensasState state) {
    return IconButton(
      onPressed: state is DespensasRefreshing
          ? null
          : () => context.read<DespensasBloc>().add(const RefreshDespensas()),
      icon: Icon(
        Icons.refresh,
        color: state is DespensasRefreshing
            ? AppTheme.textSecondary.withValues(alpha: 0.5)
            : AppTheme.textSecondary,
      ),
      tooltip: 'Atualizar',
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.error.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar despensas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<DespensasBloc>().add(const LoadDespensas()),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<DespensasBloc, DespensasState>(
      builder: (context, state) {
        // Não mostra o FAB durante loading inicial ou se está processando
        if (state is DespensasLoading || 
            (state is DespensaOperationLoading && state.operation == 'create')) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: () => _showCreateDespensaDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Nova Despensa'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, DespensasState state) {
    // Limpa mensagens antigas
    if (state is DespensasLoaded && state.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.successMessage!),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              context.read<DespensasBloc>().add(const ClearDespensaMessage());
            },
          ),
        ),
      );
    }

    // Mostra erro
    if (state is DespensasError && 
        state.despensas != null && 
        state.despensas!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // Mostra dialog de upgrade necessário
    if (state is DespensasUpgradeRequired) {
      showUpgradeRequiredDialog(
        context: context,
        title: 'Upgrade Necessário',
        message: state.message,
        upgradeMessage: state.upgradeMessage,
        currentPlan: state.currentPlan,
        limit: state.limit,
        feature: state.feature,
        onUpgrade: () {
          Navigator.of(context).pop();
          // TODO: Navegar para tela de assinatura
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionalidade de upgrade em desenvolvimento'),
            ),
          );
        },
        onDismiss: () => Navigator.of(context).pop(),
      );
    }
  }

  void _showCreateDespensaDialog(BuildContext context) {
    showCriarDespensaDialog(
      context: context,
      onSubmit: (dto) {
        Navigator.of(context).pop();
        context.read<DespensasBloc>().add(CreateDespensa(dto));
      },
    );
  }

  void _showEditDespensaDialog(BuildContext context, Despensa despensa) {
    showEditarDespensaDialog(
      context: context,
      despensa: despensa,
      onSubmit: (dto) {
        Navigator.of(context).pop();
        context.read<DespensasBloc>().add(UpdateDespensa(despensa.id, dto));
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic despensa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja deletar a despensa "${despensa.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DespensasBloc>().add(DeleteDespensa(despensa.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog(BuildContext context, int despensaId) {
    showConvidarMembroDialog(
      context: context,
      despensaId: despensaId,
      onSubmit: (dto) {
        Navigator.of(context).pop();
        context.read<DespensasBloc>().add(ConvidarMembro(despensaId, dto));
      },
    );
  }

  void _navigateToDespensaDetalhes(BuildContext context, int despensaId) {
    final despensas = _getDespensas(context.read<DespensasBloc>().state);
    final despensa = despensas.firstWhere(
      (d) => d.id == despensaId,
      orElse: () => throw Exception('Despensa não encontrada'),
    );

    Navigator.of(context).pushNamed(
      '/despensa-detalhes',
      arguments: {
        'despensaId': despensaId,
        'despensaNome': despensa.nome,
      },
    );
  }

  String _getSubtitle(DespensasState state) {
    if (state is DespensasLoaded) {
      final count = state.despensas.length;
      if (count == 0) {
        return 'Nenhuma despensa encontrada';
      } else if (count == 1) {
        return '1 despensa encontrada';
      } else {
        return '$count despensas encontradas';
      }
    } else if (state is DespensasRefreshing) {
      return 'Atualizando despensas...';
    } else if (state is DespensaOperationLoading) {
      switch (state.operation) {
        case 'create':
          return 'Criando nova despensa...';
        case 'update':
          return 'Atualizando despensa...';
        case 'delete':
          return 'Removendo despensa...';
        default:
          return 'Processando...';
      }
    } else if (state is DespensasUpgradeRequired) {
      final count = state.despensas.length;
      return '$count despensas • Upgrade necessário';
    }
    return 'Organize os itens da sua casa em diferentes locais';
  }

  List<Despensa> _getDespensas(DespensasState state) {
    if (state is DespensasLoaded) {
      return state.despensas;
    } else if (state is DespensasRefreshing) {
      return state.despensas;
    } else if (state is DespensasError && state.despensas != null) {
      return state.despensas!;
    } else if (state is DespensasUpgradeRequired) {
      return state.despensas;
    } else if (state is DespensaOperationLoading) {
      return state.despensas;
    }
    return <Despensa>[];
  }

  Widget _buildErrorState(BuildContext context, DespensasError state) {
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
            'Erro ao carregar despensas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<DespensasBloc>().add(const LoadDespensas()),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
} 