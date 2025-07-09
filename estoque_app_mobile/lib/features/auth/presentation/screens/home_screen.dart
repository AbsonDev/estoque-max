import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/auth_bloc.dart';
import '../../data/auth_event.dart';
import '../../data/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 900;
                  final isTablet =
                      constraints.maxWidth > 600 && constraints.maxWidth <= 900;

                  return Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 1200 : double.infinity,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isWideScreen ? 40 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, state, isWideScreen),
                            SizedBox(height: isWideScreen ? 40 : 32),

                            if (isWideScreen)
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: _buildAccountInfo(context, state),
                                    ),
                                    const SizedBox(width: 40),
                                    Expanded(
                                      flex: 1,
                                      child: _buildNextSteps(
                                        context,
                                        isWideScreen,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Column(
                                children: [
                                  _buildAccountInfo(context, state),
                                  SizedBox(height: isTablet ? 40 : 32),
                                  _buildNextSteps(context, isWideScreen),
                                ],
                              ),

                            SizedBox(height: isWideScreen ? 40 : 32),
                            _buildQuickActions(context, isWideScreen),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AuthState state,
    bool isWideScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isWideScreen ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryVariant.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: isWideScreen ? 80 : 60,
            height: isWideScreen ? 80 : 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryVariant],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isWideScreen ? 40 : 30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              color: AppTheme.onPrimary,
              size: isWideScreen ? 40 : 30,
            ),
          ),
          SizedBox(width: isWideScreen ? 24 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${state is AuthAuthenticated ? (state.user?.nome ?? 'usuário') : 'usuário'}!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    fontSize: isWideScreen ? 32 : 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bem-vindo ao EstoqueMax - Gerencie seu estoque de forma inteligente',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: isWideScreen ? 18 : 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: AppTheme.textSecondary),
              tooltip: 'Sair',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context, AuthState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Informações da Conta',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            context,
            icon: Icons.person_outline,
            label: 'Nome',
            value: state is AuthAuthenticated
                ? (state.user?.nome ?? 'Não informado')
                : 'Não informado',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            icon: Icons.email_outlined,
            label: 'Email',
            value: state is AuthAuthenticated
                ? (state.user?.email ?? 'Não informado')
                : 'Não informado',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            icon: Icons.security_outlined,
            label: 'Provedor',
            value: state is AuthAuthenticated
                ? (state.user?.provider ?? 'EstoqueMax')
                : 'EstoqueMax',
          ),
        ],
      ),
    );
  }

  Widget _buildNextSteps(BuildContext context, bool isWideScreen) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rocket_launch_outlined,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Primeiros Passos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'Gerenciar Despensas',
            description: 'Organize itens por locais da casa',
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).pushNamed('/despensas');
            },
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.analytics_outlined,
            title: 'Ver Análises',
            description: 'Acompanhe seus gastos e consumo',
            color: Colors.green,
            onTap: () {
              // TODO: Implementar navegação para análises
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade em desenvolvimento'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.family_restroom_outlined,
            title: 'Compartilhamento Familiar',
            description: 'Compartilhe com sua família',
            color: Colors.orange,
            onTap: () {
              // TODO: Implementar navegação para partilha familiar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade em desenvolvimento'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isWideScreen) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryVariant.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_outlined,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Ações Rápidas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildQuickActionButton(
                context,
                icon: Icons.home_work_outlined,
                label: 'Minhas Despensas',
                onTap: () {
                  Navigator.of(context).pushNamed('/despensas');
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.shopping_cart_outlined,
                label: 'Lista de Compras',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento'),
                    ),
                  );
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.bar_chart_outlined,
                label: 'Relatórios',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento'),
                    ),
                  );
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.settings_outlined,
                label: 'Configurações',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
