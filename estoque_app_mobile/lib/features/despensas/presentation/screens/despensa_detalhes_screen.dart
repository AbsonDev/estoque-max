import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/despensas_bloc.dart';
import '../bloc/despensas_event.dart';
import '../bloc/despensas_state.dart';
import '../../data/models/despensa.dart';
import '../widgets/editar_despensa_dialog.dart';
import '../widgets/convidar_membro_dialog.dart';
import '../../../../core/theme/app_theme.dart';

class DespensaDetalhesScreen extends StatefulWidget {
  final int despensaId;
  final String? despensaNome;

  const DespensaDetalhesScreen({
    Key? key,
    required this.despensaId,
    this.despensaNome,
  }) : super(key: key);

  @override
  State<DespensaDetalhesScreen> createState() => _DespensaDetalhesScreenState();
}

class _DespensaDetalhesScreenState extends State<DespensaDetalhesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Despensa? _despensa;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Verifica se o ID é válido antes de carregar
    if (widget.despensaId <= 0) {
      // ID inválido, volta para a lista de despensas
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/despensas');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID da despensa inválido'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }
    
    // Carrega os detalhes da despensa
    context.read<DespensasBloc>().add(LoadDespensaDetalhes(widget.despensaId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.despensaNome ?? 'Detalhes da Despensa'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_despensa != null && _despensa!.sounDono) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'convidar':
                    _showConvidarMembroDialog();
                    break;
                  case 'deletar':
                    _showDeleteConfirmation();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'convidar',
                  child: Row(
                    children: [
                      Icon(Icons.person_add),
                      SizedBox(width: 8),
                      Text('Convidar Membro'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'deletar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Deletar Despensa', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.info_outline),
              text: 'Informações',
            ),
            Tab(
              icon: Icon(Icons.people_outline),
              text: 'Membros',
            ),
          ],
        ),
      ),
      body: BlocConsumer<DespensasBloc, DespensasState>(
        listener: (context, state) {
          if (state is DespensasError) {
            print('Erro ao carregar detalhes da despensa: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
                action: SnackBarAction(
                  label: 'Voltar',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/despensas');
                  },
                ),
              ),
            );
          } else if (state is DespensasLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppTheme.success,
              ),
            );
          }
        },
        builder: (context, state) {
          print('Estado atual da tela de detalhes: ${state.runtimeType}');
          
          if (state is DespensasLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DespensaDetalhesLoaded) {
            try {
              _despensa = state.despensa;
              print('Despensa carregada: ID=${state.despensa.id}, Nome=${state.despensa.nome}');
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildInformacoesTab(state.despensa),
                  _buildMembrosTab(state.despensa),
                ],
              );
            } catch (e) {
              print('Erro ao construir TabBarView: $e');
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
                      'Erro ao exibir detalhes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Erro: $e',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/despensas');
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                    ),
                  ],
                ),
              );
            }
          }

          if (state is DespensasError) {
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
                    'Erro ao carregar detalhes',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<DespensasBloc>().add(
                            LoadDespensaDetalhes(widget.despensaId),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/despensas');
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // Estado padrão ou desconhecido
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Carregando detalhes da despensa...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${widget.despensaId}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInformacoesTab(Despensa despensa) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card principal da despensa
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTipoIcon(despensa.nome),
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              despensa.nome,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              despensa.meuPapel,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (despensa.sounDono)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Proprietário',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.amber[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.calendar_today,
                          label: 'Criada em',
                          value: _formatarData(despensa.dataCriacao),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.people,
                          label: 'Membros',
                          value: '${despensa.membros.length}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.inventory,
                          label: 'Itens',
                          value: '${despensa.itens?.length ?? 0}',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.update,
                          label: 'Atualizada em',
                          value: _formatarData(despensa.dataCriacao),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Card de itens (preview)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Itens da Despensa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (despensa.itens?.isEmpty ?? true)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhum item cadastrado',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: (despensa.itens ?? []).take(3).map((item) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.shopping_basket,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(item.produto),
                          subtitle: Text('Quantidade: ${item.quantidade}'),
                          trailing: item.dataValidade != null
                              ? Chip(
                                  label: Text(
                                    _formatarData(item.dataValidade!),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: _getVencimentoColor(item.dataValidade!),
                                )
                              : null,
                        );
                      }).toList(),
                    ),
                  if ((despensa.itens?.length ?? 0) > 3) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navegar para lista completa de itens
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em desenvolvimento'),
                            ),
                          );
                        },
                        child: Text(
                          'Ver todos os ${despensa.itens?.length ?? 0} itens',
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembrosTab(Despensa despensa) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com botão de adicionar membro
          Row(
            children: [
              const Text(
                'Membros da Despensa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (despensa.sounDono)
                ElevatedButton.icon(
                  onPressed: _showConvidarMembroDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Convidar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Lista de membros
          Card(
            elevation: 2,
            child: Column(
              children: despensa.membros.map((membro) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      membro.nome[0].toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(membro.nome),
                  subtitle: Text(membro.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: membro.papel == 'Dono'
                              ? Colors.amber.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          membro.papel,
                          style: TextStyle(
                            fontSize: 10,
                            color: membro.papel == 'Dono'
                                ? Colors.amber[700]
                                : Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (despensa.sounDono && membro.papel != 'Dono')
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'remover') {
                              _showRemoverMembroConfirmation(membro);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'remover',
                              child: Row(
                                children: [
                                  Icon(Icons.person_remove, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Remover', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'cozinha':
        return Icons.kitchen;
      case 'despensa':
        return Icons.store;
      case 'geladeira':
        return Icons.kitchen;
      case 'freezer':
        return Icons.ac_unit;
      case 'armário':
        return Icons.door_front_door;
      case 'quarto':
        return Icons.bed;
      case 'banheiro':
        return Icons.bathroom;
      case 'escritório':
        return Icons.business;
      case 'garagem':
        return Icons.garage;
      default:
        return Icons.storage;
    }
  }

  Color _getVencimentoColor(DateTime vencimento) {
    final agora = DateTime.now();
    final diferenca = vencimento.difference(agora).inDays;
    
    if (diferenca < 0) {
      return Colors.red.withOpacity(0.2);
    } else if (diferenca <= 7) {
      return Colors.orange.withOpacity(0.2);
    } else {
      return Colors.green.withOpacity(0.2);
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  void _showEditDialog() {
    if (_despensa == null) return;
    
    showEditarDespensaDialog(
      context: context,
      despensa: _despensa!,
      onSubmit: (dto) {
        Navigator.of(context).pop();
        context.read<DespensasBloc>().add(UpdateDespensa(_despensa!.id, dto));
      },
    );
  }

  void _showConvidarMembroDialog() {
    if (_despensa == null) return;
    
    showConvidarMembroDialog(
      context: context,
      despensaId: _despensa!.id,
      onSubmit: (dto) {
        Navigator.of(context).pop();
        context.read<DespensasBloc>().add(ConvidarMembro(_despensa!.id, dto));
      },
    );
  }

  void _showRemoverMembroConfirmation(MembroDespensa membro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar remoção'),
        content: Text('Tem certeza que deseja remover ${membro.nome} da despensa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DespensasBloc>().add(
                RemoverMembro(_despensa!.id, membro.usuarioId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    if (_despensa == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja deletar a despensa "${_despensa!.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DespensasBloc>().add(DeleteDespensa(_despensa!.id));
              Navigator.of(context).pop(); // Volta para a lista
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
} 