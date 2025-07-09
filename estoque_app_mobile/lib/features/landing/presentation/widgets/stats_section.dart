import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/responsive/responsive_utils.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/animations/app_animations.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: ResponsiveColumn(
        spacing: DesignTokens.spacing32,
        children: [
          Text(
            'Confiado por milhares de usuários',
            style: AppTypography.headline4(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate(effects: AppAnimations.fadeIn()),
          
          ResponsiveUtils.isLargeScreen(context)
              ? _buildStatsRow(context)
              : _buildStatsColumn(context),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _buildStatItems(context),
    );
  }

  Widget _buildStatsColumn(BuildContext context) {
    return ResponsiveColumn(
      spacing: DesignTokens.spacing24,
      children: _buildStatItems(context),
    );
  }

  List<Widget> _buildStatItems(BuildContext context) {
    final stats = [
      _StatData(
        value: 15000,
        suffix: '+',
        label: 'Usuários Ativos',
        icon: Icons.people_rounded,
        color: AppColors.primary,
      ),
      _StatData(
        value: 50000,
        suffix: '+',
        label: 'Produtos Cadastrados',
        icon: Icons.inventory_2_rounded,
        color: AppColors.secondary,
      ),
      _StatData(
        value: 95,
        suffix: '%',
        label: 'Satisfação',
        icon: Icons.thumb_up_rounded,
        color: AppColors.success,
      ),
      _StatData(
        value: 24,
        suffix: '/7',
        label: 'Disponibilidade',
        icon: Icons.access_time_rounded,
        color: AppColors.warning,
      ),
    ];

    return stats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      return _buildStatCard(context, stat, index);
    }).toList();
  }

  Widget _buildStatCard(BuildContext context, _StatData stat, int index) {
    return Flexible(
      child: Container(
        padding: ResponsiveUtils.valueByScreen(
          context,
          mobile: const EdgeInsets.all(DesignTokens.spacing20),
          tablet: const EdgeInsets.all(DesignTokens.spacing24),
          desktop: const EdgeInsets.all(DesignTokens.spacing32),
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getCardBorderRadius(context),
          ),
          border: Border.all(
            color: AppColors.withOpacity(stat.color, 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.withOpacity(stat.color, 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ResponsiveColumn(
          spacing: DesignTokens.spacing16,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                color: AppColors.withOpacity(stat.color, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Icon(
                stat.icon,
                color: stat.color,
                size: ResponsiveUtils.getIconSize(
                  context,
                  DesignTokens.iconLarge,
                ),
              ),
            ),
            
            AnimatedCounter(
              value: stat.value,
              suffix: stat.suffix,
              duration: Duration(milliseconds: 1500 + (index * 200)),
              style: AppTypography.headline3(context).copyWith(
                fontWeight: FontWeight.w800,
                color: stat.color,
              ),
            ),
            
            Text(
              stat.label,
              style: AppTypography.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate(
        effects: AppAnimations.cardEntrance(),
      ),
    );
  }
}

class _StatData {
  final int value;
  final String suffix;
  final String label;
  final IconData icon;
  final Color color;

  const _StatData({
    required this.value,
    required this.suffix,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class TestimonialSection extends StatelessWidget {
  const TestimonialSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: ResponsiveColumn(
        spacing: DesignTokens.spacing32,
        children: [
          Text(
            'O que nossos usuários dizem',
            style: AppTypography.headline3(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate(effects: AppAnimations.fadeIn()),
          
          ResponsiveUtils.isLargeScreen(context)
              ? _buildTestimonialsRow(context)
              : _buildTestimonialsColumn(context),
        ],
      ),
    );
  }

  Widget _buildTestimonialsRow(BuildContext context) {
    return Row(
      children: _buildTestimonialItems(context),
    );
  }

  Widget _buildTestimonialsColumn(BuildContext context) {
    return ResponsiveColumn(
      spacing: DesignTokens.spacing20,
      children: _buildTestimonialItems(context),
    );
  }

  List<Widget> _buildTestimonialItems(BuildContext context) {
    final testimonials = [
      _TestimonialData(
        name: 'Maria Silva',
        role: 'Dona de Casa',
        content: 'Revolucionou a forma como organizo minha despensa. Nunca mais deixei comida estragar!',
        rating: 5,
        avatar: Icons.person,
      ),
      _TestimonialData(
        name: 'João Santos',
        role: 'Empresário',
        content: 'Perfeito para meu restaurante. Controlo todo o estoque de forma eficiente.',
        rating: 5,
        avatar: Icons.person,
      ),
      _TestimonialData(
        name: 'Ana Costa',
        role: 'Nutricionista',
        content: 'Recomendo para todos meus pacientes. Ajuda muito no controle alimentar.',
        rating: 5,
        avatar: Icons.person,
      ),
    ];

    return testimonials.asMap().entries.map((entry) {
      final index = entry.key;
      final testimonial = entry.value;
      return Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.isLargeScreen(context) 
                ? DesignTokens.spacing8 
                : 0,
          ),
          child: _buildTestimonialCard(context, testimonial, index),
        ),
      );
    }).toList();
  }

  Widget _buildTestimonialCard(BuildContext context, _TestimonialData testimonial, int index) {
    return Container(
      padding: ResponsiveUtils.getCardPadding(context),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardBorderRadius(context),
        ),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.withOpacity(AppColors.black, 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ResponsiveColumn(
        spacing: DesignTokens.spacing16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              testimonial.rating,
              (index) => Icon(
                Icons.star,
                color: AppColors.warning,
                size: ResponsiveUtils.getIconSize(context, DesignTokens.iconSmall),
              ),
            ),
          ),
          
          Text(
            testimonial.content,
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Icon(
                  testimonial.avatar,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: DesignTokens.spacing12),
              Expanded(
                child: ResponsiveColumn(
                  spacing: DesignTokens.spacing4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.name,
                      style: AppTypography.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      testimonial.role,
                      style: AppTypography.bodySmall(context).copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(
      effects: AppAnimations.cardEntrance(),
    );
  }
}

class _TestimonialData {
  final String name;
  final String role;
  final String content;
  final int rating;
  final IconData avatar;

  const _TestimonialData({
    required this.name,
    required this.role,
    required this.content,
    required this.rating,
    required this.avatar,
  });
}