import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/convites_bloc.dart';
import '../widgets/membro_card.dart';
import '../widgets/convite_enviar_dialog.dart';
import '../widgets/convites_empty_state.dart';
import '../widgets/convite_loading_skeleton.dart';
import '../../data/models/convite_models.dart';

class MembrosDespensaScreen extends StatefulWidget {
  final int despensaId;
  final String despensaNome;

  const MembrosDespensaScreen({
    Key? key,
    required this.despensaId,
    required this.despensaNome,
  }) : super(key: key);

  @override
  State<MembrosDespensaScreen> createState() => _MembrosDespensaScreenState();
}

class _MembrosDespensaScreenState extends State<MembrosDespensaScreen> {
  @override
  void initState() {
    super.initState();
    _loadMembros();
  }

  void _loadMembros() {
    context.read<ConvitesBloc>().add(LoadMembros(despensaId: widget.despensaId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membros - ${widget.despensaNome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              ConviteEnviarDialog.show(
                context,
                widget.despensaId,
                widget.despensaNome,
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ConvitesBloc, ConvitesState>(
        listener: (context, state) {
          if (state is ConvitesError) {
            _showErrorSnackBar(state.message);
          } else if (state is ConvitesSuccess) {
            _showSuccessSnackBar(state.message);
            _loadMembros();
          }
        },
        builder: (context, state) {
          if (state is ConvitesLoading) {
            return const ConviteLoadingSkeleton();
          }
          
          if (state is MembrosLoaded) {
            final membros = state.membros;
            
            if (membros.isEmpty) {
              return ConvitesEmptyState(
                title: 'Nenhum membro',
                subtitle: 'Esta despensa não possui membros ainda.',
                icon: Icons.people_outline,
                onActionPressed: () {
                  ConviteEnviarDialog.show(
                    context,
                    widget.despensaId,
                    widget.despensaNome,
                  );
                },
                actionText: 'Convidar',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadMembros();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: membros.length,
                itemBuilder: (context, index) {
                  final membro = membros[index];
                  return MembroCard(
                    membro: membro,
                    onRemover: () {
                      _showRemoverDialog(membro);
                    },
                    onAlterarRole: (novoRole) {
                      context.read<ConvitesBloc>().add(
                            AlterarRoleMembro(
                              despensaId: widget.despensaId,
                              membroId: membro.id,
                              novoRole: novoRole,
                            ),
                          );
                    },
                  ).animate().fadeIn(duration: 300.ms).slideY(
                        begin: 0.2,
                        duration: 300.ms,
                        curve: Curves.easeOutCubic,
                      );
                },
              ),
            );
          }

          return const ConvitesEmptyState(
            title: 'Erro ao carregar membros',
            subtitle: 'Tente novamente mais tarde',
            icon: Icons.error_outline,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ConviteEnviarDialog.show(
            context,
            widget.despensaId,
            widget.despensaNome,
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showRemoverDialog(MembroDespensa membro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Membro'),
        content: Text(
          'Tem certeza que deseja remover ${membro.nome} desta despensa?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ConvitesBloc>().add(
                    RemoverMembro(
                      despensaId: widget.despensaId,
                      membroId: membro.id,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 