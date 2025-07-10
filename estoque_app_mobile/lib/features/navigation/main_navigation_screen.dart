import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_typography.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../core/widgets/responsive_navigation.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/responsive_buttons.dart';
import '../../core/animations/app_animations.dart';
import '../auth/data/auth_bloc.dart';
import '../auth/data/auth_event.dart';
import '../auth/data/auth_state.dart';
import '../despensas/presentation/screens/despensas_screen.dart';
import '../estoque/presentation/screens/estoque_screen.dart';
import '../lista_compras/presentation/screens/lista_compras_screen.dart';
import '../analytics/presentation/screens/analytics_screen.dart';
import 'widgets/floating_action_menu.dart';
import '../subscription/presentation/bloc/subscription_bloc.dart';
import '../subscription/data/models/subscription_models.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isMenuVisible = false;
  bool _isSidebarCollapsed = false;
  late AnimationController _fabAnimationController;
  late AnimationController _menuAnimationController;

  late List<ResponsiveNavigationItem> _navigationItems;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: DesignTokens.animationMedium,
      vsync: this,
    );
    _menuAnimationController = AnimationController(
      duration: DesignTokens.animationMedium,
      vsync: this,
    );
    _initializeNavigationItems();
  }

  void _initializeNavigationItems() {
    _navigationItems = [
      ResponsiveNavigationItem(
        id: 'despensas',
        label: 'Despensas',
        icon: Icons.home_rounded,
        activeIcon: Icons.home,
        isActive: _currentIndex == 0,
        onTap: () => _onNavigationItemTapped(0),
        color: AppColors.primary,
      ),
      ResponsiveNavigationItem(
        id: 'estoque',
        label: 'Estoque',
        icon: Icons.inventory_2_rounded,
        activeIcon: Icons.inventory_2,
        isActive: _currentIndex == 1,
        onTap: () => _onNavigationItemTapped(1),
        color: AppColors.secondary,
      ),
      ResponsiveNavigationItem(
        id: 'lista',
        label: 'Lista',
        icon: Icons.shopping_cart_rounded,
        activeIcon: Icons.shopping_cart,
        isActive: _currentIndex == 2,
        onTap: () => _onNavigationItemTapped(2),
        color: AppColors.warning,
      ),
      ResponsiveNavigationItem(
        id: 'analytics',
        label: 'Analytics',
        icon: Icons.analytics_rounded,
        activeIcon: Icons.analytics,
        isActive: _currentIndex == 3,
        onTap: () => _onNavigationItemTapped(3),
        color: AppColors.success,
      ),
    ];
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _initializeNavigationItems();
    });
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

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
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

  Widget _buildSidebarHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isSidebarCollapsed) ...[
              Text(
                'EstoqueMax',
                style: AppTypography.headline5(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing8),
              Row(
                children: [
                  CircleAvatar(
                    radius: ResponsiveUtils.getFontSize(context, 16),
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: ResponsiveUtils.getIconSize(
                        context,
                        DesignTokens.iconSmall,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state is AuthAuthenticated
                              ? (state.user?.nome ?? 'Usuário')
                              : 'Usuário',
                          style: AppTypography.bodyMedium(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        _buildSubscriptionBadge(compact: true),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Center(
                child: Icon(
                  Icons.dashboard_rounded,
                  color: AppColors.primary,
                  size: ResponsiveUtils.getIconSize(
                    context,
                    DesignTokens.iconLarge,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSidebarFooter(BuildContext context) {
    return Column(
      children: [
        if (!_isSidebarCollapsed) ...[
          ResponsiveButton(
            text: 'Sair',
            variant: ButtonVariant.ghost,
            size: ButtonSize.small,
            isFullWidth: true,
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ] else ...[
          ResponsiveIconButton(
            icon: const Icon(Icons.logout),
            variant: ButtonVariant.ghost,
            size: ButtonSize.small,
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Sair',
          ),
        ],
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ResponsiveContainer(
          padding: ResponsiveUtils.getPagePadding(context),
          child: Row(
            children: [
              // Subscription badge (left side)
              _buildSubscriptionBadge(),
              const Spacer(),
              // User info and logout (right side)
              if (ResponsiveUtils.isSmallScreen(context)) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing12,
                    vertical: DesignTokens.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusLarge,
                    ),
                    boxShadow: DesignTokens.shadowSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: ResponsiveUtils.getFontSize(context, 12),
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.person,
                          color: AppColors.white,
                          size: ResponsiveUtils.getIconSize(
                            context,
                            DesignTokens.iconSmall,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing8),
                      Text(
                        state is AuthAuthenticated
                            ? (state.user?.nome ?? 'Usuário')
                            : 'Usuário',
                        style: AppTypography.bodySmall(
                          context,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DesignTokens.spacing8),
                ResponsiveIconButton(
                  icon: const Icon(Icons.logout),
                  variant: ButtonVariant.tertiary,
                  size: ButtonSize.small,
                  customColor: AppColors.error,
                  onPressed: () => _showLogoutDialog(context),
                  tooltip: 'Sair',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveNavigationWrapper(
      items: _navigationItems,
      currentIndex: _currentIndex,
      onTap: _onNavigationItemTapped,
      sidebarHeader: _buildSidebarHeader(context),
      sidebarFooter: _buildSidebarFooter(context),
      isCollapsed: _isSidebarCollapsed,
      onToggleCollapse: _toggleSidebar,
      child: ResponsiveScaffold(
        backgroundColor: AppColors.background,
        applySafeArea: true,
        centerContent: false,
        body: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Top bar for mobile/tablet
                if (ResponsiveUtils.shouldShowBottomNavigation(context)) ...[
                  _buildTopBar(context),
                  const SizedBox(height: DesignTokens.spacing16),
                ],
                Expanded(
                  child: ResponsiveUtils.isWebLayout(context)
                      ? _buildWebContent(context)
                      : AnimatedSwitcher(
                          duration: DesignTokens.animationMedium,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position: animation.drive(
                                    Tween<Offset>(
                                      begin: const Offset(0.1, 0.0),
                                      end: Offset.zero,
                                    ),
                                  ),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                          child: _buildCurrentPage(),
                        ),
                ),
              ],
            ),

            // Floating Action Menu
            if (_isMenuVisible)
              FloatingActionMenu(
                animationController: _menuAnimationController,
                onClose: _toggleMenu,
              ),
          ],
        ),
        floatingActionButton: ResponsiveUtils.shouldShowFab(context)
            ? ResponsiveFloatingActionButton(
                onPressed: _toggleMenu,
                tooltip: 'Menu de ações',
                child: AnimatedBuilder(
                  animation: _fabAnimationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _fabAnimationController.value * 0.785,
                      child: Icon(
                        _isMenuVisible ? Icons.close : Icons.add,
                        color: AppColors.white,
                      ),
                    );
                  },
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildSubscriptionBadge({bool compact = false}) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        String planName = 'Free';
        Color gradientStart = AppColors.warning;
        Color gradientEnd = AppColors.secondaryVariant;
        IconData icon = Icons.star;

        if (state is SubscriptionLoaded) {
          // Encontrar o tier correspondente ao tierId da subscription
          final tier = state.availableTiers.firstWhere(
            (tier) => tier.id == state.subscription.tierId,
            orElse: () => SubscriptionTier(
              id: 'free',
              name: 'Free',
              description: 'Plano gratuito',
              price: 0.0,
              currency: 'EUR',
              interval: 'month',
              features: [],
              limits: {},
            ),
          );

          planName = tier.name;
          if (planName.toLowerCase().contains('premium')) {
            gradientStart = AppColors.primary;
            gradientEnd = AppColors.primaryVariant;
            icon = Icons.workspace_premium;
          }
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact
                ? DesignTokens.spacing8
                : DesignTokens.spacing12,
            vertical: compact ? DesignTokens.spacing4 : DesignTokens.spacing8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(
              compact ? DesignTokens.radiusMedium : DesignTokens.radiusLarge,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.withOpacity(gradientStart, 0.3),
                blurRadius: compact ? 6 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.white,
                size: ResponsiveUtils.getIconSize(
                  context,
                  compact ? DesignTokens.iconSmall : DesignTokens.iconMedium,
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: DesignTokens.spacing4),
                Text(
                  planName,
                  style: AppTypography.bodySmall(context).copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ).animate(effects: AppAnimations.slideInFromLeft());
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getCardBorderRadius(context),
          ),
        ),
        title: Text('Sair', style: AppTypography.headline6(context)),
        content: Text(
          'Tem certeza que deseja sair da aplicação?',
          style: AppTypography.bodyMedium(context),
        ),
        actions: [
          ResponsiveButton(
            text: 'Cancelar',
            variant: ButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          ResponsiveButton(
            text: 'Sair',
            variant: ButtonVariant.danger,
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebContent(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardBorderRadius(context),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: AppColors.withOpacity(AppColors.black, 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: DesignTokens.animationMedium,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(
                      begin: const Offset(0.05, 0.0),
                      end: Offset.zero,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: _buildCurrentPage(),
          ),
        ),
      ),
    );
  }
}
