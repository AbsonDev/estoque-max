import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/responsive/responsive_utils.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/responsive_buttons.dart';
import '../../../../core/animations/app_animations.dart';
import '../widgets/stats_section.dart';
import '../widgets/animated_logo.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background with animated particles
          _buildAnimatedBackground(),
          
          // Main content
          _buildMainContent(context),
          
          // Floating elements
          _buildFloatingElements(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.withOpacity(AppColors.primary, 0.05),
            AppColors.withOpacity(AppColors.secondary, 0.03),
            AppColors.background,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlesPainter(_particleController.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return ResponsiveContainer(
      centerContent: true,
      child: SingleChildScrollView(
        child: ResponsiveColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: ResponsiveUtils.valueByScreen(
            context,
            mobile: DesignTokens.spacing32,
            tablet: DesignTokens.spacing40,
            desktop: DesignTokens.spacing48,
          ),
          children: [
            // Hero section
            _buildHeroSection(context),
            
            // Features section
            _buildFeaturesSection(context),
            
            // Stats section
            const StatsSection(),
            
            // Testimonials section
            const TestimonialSection(),
            
            // CTA section
            _buildCTASection(context),
            
            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return ResponsiveColumn(
      spacing: DesignTokens.spacing24,
      children: [
        // Logo and app icon
        _buildLogo(context),
        
        // Main title
        Text(
          'EstoqueMax',
          style: ResponsiveUtils.valueByScreen(
            context,
            mobile: AppTypography.display2(context),
            tablet: AppTypography.display1(context),
            desktop: AppTypography.display1(context).copyWith(
              fontSize: ResponsiveUtils.getFontSize(context, 72),
            ),
          ).copyWith(
            fontWeight: FontWeight.w900,
            background: Paint()
              ..shader = AppColors.primaryGradient.createShader(
                const Rect.fromLTWH(0, 0, 400, 100),
              ),
          ),
          textAlign: TextAlign.center,
        ).animate(effects: AppAnimations.slideInFromTop()),
        
        // Subtitle
        Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.valueByScreen(
              context,
              mobile: 300,
              tablet: 500,
              desktop: 600,
            ),
          ),
          child: Text(
            'Gerencie seu estoque de forma inteligente e eficiente. '
            'Controle suas despensas, liste suas compras e tenha '
            'insights poderosos sobre seu inventário.',
            style: AppTypography.bodyLarge(context).copyWith(
              fontSize: ResponsiveUtils.getFontSize(context, 18),
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate(effects: AppAnimations.slideInFromBottom()),
        
        // Version badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing16,
            vertical: DesignTokens.spacing8,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.withOpacity(AppColors.secondary, 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.white,
                size: ResponsiveUtils.getIconSize(context, DesignTokens.iconSmall),
              ),
              const SizedBox(width: DesignTokens.spacing8),
              Text(
                'Versão 2.0 - Totalmente Redesenhado',
                style: AppTypography.labelMedium(context).copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ).animate(effects: AppAnimations.scaleIn()),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    return AnimatedLogo(
      size: ResponsiveUtils.valueByScreen(
        context,
        mobile: 120,
        tablet: 140,
        desktop: 160,
      ),
      onTap: () => _showAppInfo(context),
    ).animate(effects: AppAnimations.bounceIn());
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      _FeatureData(
        icon: Icons.home_rounded,
        title: 'Gestão de Despensas',
        description: 'Organize suas despensas e mantenha controle total do que você possui.',
        gradient: AppColors.primaryGradient,
      ),
      _FeatureData(
        icon: Icons.inventory_2_rounded,
        title: 'Controle de Estoque',
        description: 'Monitore quantidades, validades e receba alertas inteligentes.',
        gradient: AppColors.secondaryGradient,
      ),
      _FeatureData(
        icon: Icons.shopping_cart_rounded,
        title: 'Lista de Compras',
        description: 'Crie listas inteligentes baseadas no seu histórico de consumo.',
        gradient: AppColors.warningGradient,
      ),
      _FeatureData(
        icon: Icons.analytics_rounded,
        title: 'Analytics Avançados',
        description: 'Insights poderosos sobre seus hábitos de consumo e gastos.',
        gradient: AppColors.successGradient,
      ),
    ];

    return ResponsiveColumn(
      spacing: DesignTokens.spacing32,
      children: [
        Text(
          'Recursos Poderosos',
          style: AppTypography.headline2(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate(effects: AppAnimations.slideInFromTop()),
        
        ResponsiveUtils.isLargeScreen(context)
            ? _buildFeaturesGrid(features)
            : _buildFeaturesColumn(features),
      ],
    );
  }

  Widget _buildFeaturesGrid(List<_FeatureData> features) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.valueByScreen(
          context,
          mobile: 1,
          tablet: 2,
          desktop: 2,
        ),
        mainAxisSpacing: DesignTokens.spacing24,
        crossAxisSpacing: DesignTokens.spacing24,
        childAspectRatio: ResponsiveUtils.valueByScreen(
          context,
          mobile: 1.2,
          tablet: 1.1,
          desktop: 1.3,
        ),
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(features[index], index);
      },
    );
  }

  Widget _buildFeaturesColumn(List<_FeatureData> features) {
    return ResponsiveColumn(
      spacing: DesignTokens.spacing20,
      children: features.asMap().entries.map((entry) {
        return _buildFeatureCard(entry.value, entry.key);
      }).toList(),
    );
  }

  Widget _buildFeatureCard(_FeatureData feature, int index) {
    return Container(
      padding: ResponsiveUtils.getCardPadding(context),
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardBorderRadius(context),
        ),
        border: Border.all(
          color: AppColors.withOpacity(AppColors.border, 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.withOpacity(AppColors.black, 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ResponsiveColumn(
        spacing: DesignTokens.spacing16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: ResponsiveUtils.valueByScreen(
              context,
              mobile: 48,
              tablet: 56,
              desktop: 64,
            ),
            height: ResponsiveUtils.valueByScreen(
              context,
              mobile: 48,
              tablet: 56,
              desktop: 64,
            ),
            decoration: BoxDecoration(
              gradient: feature.gradient,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: Icon(
              feature.icon,
              color: AppColors.white,
              size: ResponsiveUtils.getIconSize(
                context,
                DesignTokens.iconLarge,
              ),
            ),
          ),
          Text(
            feature.title,
            style: AppTypography.headline5(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            feature.description,
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate(
      effects: AppAnimations.cardEntrance(),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getCardPadding(context),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardBorderRadius(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.withOpacity(AppColors.primary, 0.4),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ResponsiveColumn(
        spacing: DesignTokens.spacing24,
        children: [
          Text(
            'Pronto para revolucionar\nseu controle de estoque?',
            style: AppTypography.headline3(context).copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Junte-se a milhares de usuários que já transformaram '
            'a forma como gerenciam seus estoques.',
            style: AppTypography.bodyLarge(context).copyWith(
              color: AppColors.withOpacity(AppColors.white, 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          ResponsiveRow(
            mainAxisAlignment: MainAxisAlignment.center,
            wrapOnMobile: true,
            spacing: DesignTokens.spacing16,
            children: [
              ResponsiveButton(
                text: 'Começar Agora',
                variant: ButtonVariant.tertiary,
                size: ButtonSize.large,
                icon: const Icon(Icons.arrow_forward),
                iconOnRight: true,
                onPressed: () => _navigateToAuth(context),
              ),
              ResponsiveButton(
                text: 'Saber Mais',
                variant: ButtonVariant.ghost,
                size: ButtonSize.large,
                customColor: AppColors.white,
                onPressed: () => _showFeatures(context),
              ),
            ],
          ),
        ],
      ),
    ).animate(effects: AppAnimations.modalEntrance());
  }

  Widget _buildFooter(BuildContext context) {
    return ResponsiveColumn(
      spacing: DesignTokens.spacing16,
      children: [
        Divider(
          color: AppColors.withOpacity(AppColors.border, 0.3),
        ),
        ResponsiveRow(
          mainAxisAlignment: MainAxisAlignment.center,
          wrapOnMobile: true,
          spacing: DesignTokens.spacing24,
          children: [
            Text(
              '© 2024 EstoqueMax',
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              'Feito com ❤️ para você',
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    ).animate(effects: AppAnimations.fadeIn());
  }

  Widget _buildFloatingElements() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Stack(
              children: [
                // Floating shapes
                ..._generateFloatingShapes(),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _generateFloatingShapes() {
    final shapes = <Widget>[];
    final screenSize = MediaQuery.of(context).size;
    
    for (int i = 0; i < 6; i++) {
      final size = 20.0 + (i * 10);
      
      shapes.add(
        Positioned(
          left: (i * 120.0) % screenSize.width,
          top: (i * 150.0) % screenSize.height,
          child: Transform.translate(
            offset: Offset(
              20 * _floatingController.value * (i.isEven ? 1 : -1),
              15 * _floatingController.value,
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: i.isEven 
                    ? AppColors.primaryGradient 
                    : AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(size / 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.withOpacity(
                      i.isEven ? AppColors.primary : AppColors.secondary,
                      0.2,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return shapes;
  }

  void _navigateToAuth(BuildContext context) {
    Navigator.of(context).pushNamed('/login');
  }

  void _showFeatures(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FeaturesBottomSheet(),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getCardBorderRadius(context),
          ),
        ),
        title: Row(
          children: [
            AnimatedLogo(
              size: 40,
              onTap: null,
            ),
            const SizedBox(width: DesignTokens.spacing12),
            Text(
              'EstoqueMax',
              style: AppTypography.headline6(context),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versão 2.0.0',
              style: AppTypography.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Text(
              'O EstoqueMax é a solução definitiva para gerenciamento '
              'inteligente de estoques e despensas. Desenvolvido com '
              'tecnologia de ponta e design moderno.',
              style: AppTypography.bodyMedium(context),
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Text(
              '© 2024 EstoqueMax. Todos os direitos reservados.',
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          ResponsiveButton(
            text: 'Fechar',
            variant: ButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (i * 50.0 + animationValue * 100) % size.width;
      final y = (i * 80.0 + animationValue * 50) % size.height;
      final opacity = (0.1 + (i % 3) * 0.05);
      
      paint.color = AppColors.withOpacity(
        i.isEven ? AppColors.primary : AppColors.secondary,
        opacity,
      );
      
      canvas.drawCircle(
        Offset(x, y),
        2.0 + (i % 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FeaturesBottomSheet extends StatelessWidget {
  const _FeaturesBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLarge),
        ),
      ),
      child: ResponsiveContainer(
        padding: ResponsiveUtils.getPagePadding(context),
        child: ResponsiveColumn(
          spacing: DesignTokens.spacing24,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Recursos Detalhados',
              style: AppTypography.headline4(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ResponsiveColumn(
                  spacing: DesignTokens.spacing20,
                  children: [
                    _buildDetailedFeature(
                      context,
                      'Gestão Inteligente de Despensas',
                      'Organize múltiplas despensas, categorize produtos e mantenha '
                      'controle visual de tudo que você possui.',
                      Icons.home_rounded,
                    ),
                    _buildDetailedFeature(
                      context,
                      'Controle de Validade Automático',
                      'Receba notificações antes dos produtos vencerem e evite '
                      'desperdícios desnecessários.',
                      Icons.schedule,
                    ),
                    _buildDetailedFeature(
                      context,
                      'Sincronização em Tempo Real',
                      'Todos os seus dados sincronizados em tempo real entre '
                      'todos os seus dispositivos.',
                      Icons.sync,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedFeature(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: DesignTokens.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing4),
                Text(
                  description,
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}