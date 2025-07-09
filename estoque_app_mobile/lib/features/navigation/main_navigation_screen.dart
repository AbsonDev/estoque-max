import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../auth/data/auth_bloc.dart';
import '../auth/data/auth_event.dart';
import '../auth/data/auth_state.dart';
import '../despensas/presentation/screens/despensas_screen.dart';
import '../estoque/presentation/screens/estoque_screen.dart';
import '../lista_compras/presentation/screens/lista_compras_screen.dart';
import '../analytics/presentation/screens/analytics_screen.dart';
import 'widgets/floating_action_menu.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isMenuVisible = false;
  late AnimationController _fabAnimationController;
  late AnimationController _menuAnimationController;

  final List<TabItem> _tabs = [
    TabItem(
      icon: Icons.home_rounded,
      label: 'Despensas',
      activeColor: AppTheme.primaryColor,
    ),
    TabItem(
      icon: Icons.inventory_2_rounded,
      label: 'Estoque',
      activeColor: AppTheme.secondary,
    ),
    TabItem(
      icon: Icons.shopping_cart_rounded,
      label: 'Lista',
      activeColor: AppTheme.warning,
    ),
    TabItem(
      icon: Icons.analytics_rounded,
      label: 'Analytics',
      activeColor: AppTheme.success,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _menuAnimationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuVisible = !_isMenuVisible;
    });

    if (_isMenuVisible) {
      _menuAnimationController.forward();
      _fabAnimationController.forward();
    } else {
      _menuAnimationController.reverse();
      _fabAnimationController.reverse();
    }
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const DespensasScreen();
      case 1:
        return const EstoqueScreen();
      case 2:
        return const ListaComprasScreen();
      case 3:
        return const AnalyticsScreen();
      default:
        return const DespensasScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Main content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentPage(),
              ),

              // Floating Action Menu
              if (_isMenuVisible)
                FloatingActionMenu(
                  animationController: _menuAnimationController,
                  onClose: _toggleMenu,
                ),

              // Account Info and Logout (Top Right)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.primaryColor,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state is AuthAuthenticated
                                ? (state.user?.nome ?? 'Usuário')
                                : 'Usuário',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(
                          Icons.logout,
                          color: AppTheme.error,
                          size: 20,
                        ),
                        tooltip: 'Sair',
                      ),
                    ),
                  ],
                ),
              ),

              // Subscription Badge (Top Left)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: _buildSubscriptionBadge(),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _tabs.length,
        tabBuilder: (int index, bool isActive) {
          final tab = _tabs[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tab.icon,
                size: 24,
                color: isActive ? tab.activeColor : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? tab.activeColor : AppTheme.textSecondary,
                ),
              ),
            ],
          );
        },
        backgroundColor: AppTheme.surface,
        activeIndex: _currentIndex,
        splashColor: AppTheme.primaryColor.withOpacity(0.1),
        notchAndCornersAnimation: _fabAnimationController,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMenu,
        backgroundColor: AppTheme.primaryColor,
        child: AnimatedBuilder(
          animation: _fabAnimationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _fabAnimationController.value * 0.785, // 45 degrees
              child: Icon(
                _isMenuVisible ? Icons.close : Icons.add,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSubscriptionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.warning, AppTheme.secondaryVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warning.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            'Free',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -1, end: 0);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da aplicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class TabItem {
  final IconData icon;
  final String label;
  final Color activeColor;

  TabItem({required this.icon, required this.label, required this.activeColor});
}
