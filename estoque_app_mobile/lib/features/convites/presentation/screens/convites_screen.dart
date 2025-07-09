import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/convites_bloc.dart';
import '../widgets/convite_card.dart';
import '../widgets/convites_empty_state.dart';
import '../widgets/convite_loading_skeleton.dart';

class ConvitesScreen extends StatefulWidget {
  const ConvitesScreen({Key? key}) : super(key: key);

  @override
  State<ConvitesScreen> createState() => _ConvitesScreenState();
}

class _ConvitesScreenState extends State<ConvitesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Carrega convites recebidos por padrão
    context.read<ConvitesBloc>().add(LoadConvitesRecebidos());
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
        title: const Text('Convites'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 0) {
              context.read<ConvitesBloc>().add(LoadConvitesRecebidos());
            } else {
              context.read<ConvitesBloc>().add(LoadConvitesEnviados());
            }
          },
          tabs: const [
            Tab(text: 'Recebidos'),
            Tab(text: 'Enviados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildConvitesRecebidosTab(), _buildConvitesEnviadosTab()],
      ),
    );
  }

  Widget _buildConvitesRecebidosTab() {
    return BlocConsumer<ConvitesBloc, ConvitesState>(
      listener: (context, state) {
        if (state is ConvitesError) {
          _showErrorSnackBar(state.message);
        } else if (state is ConvitesSuccess) {
          _showSuccessSnackBar(state.message);
          context.read<ConvitesBloc>().add(LoadConvitesRecebidos());
        }
      },
      builder: (context, state) {
        if (state is ConvitesLoading) {
          return const ConviteLoadingSkeleton();
        }

        if (state is ConvitesLoaded) {
          final convites = state.convitesRecebidos;

          if (convites.isEmpty) {
            return const ConvitesEmptyState(
              title: 'Nenhum convite recebido',
              subtitle: 'Você não possui convites pendentes no momento.',
              icon: Icons.inbox_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ConvitesBloc>().add(LoadConvitesRecebidos());
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: convites.length,
              itemBuilder: (context, index) {
                final convite = convites[index];
                return ConviteCard(
                  convite: convite,
                  isRecebido: true,
                  onAceitar: () {
                    context.read<ConvitesBloc>().add(
                      AceitarConvite(conviteId: convite.id),
                    );
                  },
                  onRecusar: () {
                    context.read<ConvitesBloc>().add(
                      RecusarConvite(conviteId: convite.id),
                    );
                  },
                  onDeletar: () {
                    context.read<ConvitesBloc>().add(
                      DeletarConvite(conviteId: convite.id),
                    );
                  },
                );
              },
            ),
          );
        }

        return const ConvitesEmptyState(
          title: 'Erro ao carregar convites',
          subtitle: 'Tente novamente mais tarde',
          icon: Icons.error_outline,
        );
      },
    );
  }

  Widget _buildConvitesEnviadosTab() {
    return BlocConsumer<ConvitesBloc, ConvitesState>(
      listener: (context, state) {
        if (state is ConvitesError) {
          _showErrorSnackBar(state.message);
        } else if (state is ConvitesSuccess) {
          _showSuccessSnackBar(state.message);
          context.read<ConvitesBloc>().add(LoadConvitesEnviados());
        }
      },
      builder: (context, state) {
        if (state is ConvitesLoading) {
          return const ConviteLoadingSkeleton();
        }

        if (state is ConvitesLoaded) {
          final convites = state.convitesEnviados;

          if (convites.isEmpty) {
            return const ConvitesEmptyState(
              title: 'Nenhum convite enviado',
              subtitle: 'Você ainda não enviou convites para ninguém.',
              icon: Icons.outbox_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ConvitesBloc>().add(LoadConvitesEnviados());
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: convites.length,
              itemBuilder: (context, index) {
                final convite = convites[index];
                return ConviteCard(
                  convite: convite,
                  isRecebido: false,
                  onDeletar: () {
                    context.read<ConvitesBloc>().add(
                      DeletarConvite(conviteId: convite.id),
                    );
                  },
                );
              },
            ),
          );
        }

        return const ConvitesEmptyState(
          title: 'Erro ao carregar convites',
          subtitle: 'Tente novamente mais tarde',
          icon: Icons.error_outline,
        );
      },
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
