import 'package:flutter/material.dart';
import '../responsive/responsive_utils.dart';
import '../design_system/app_colors.dart';
import '../design_system/design_tokens.dart';

class WebPageLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final EdgeInsets? padding;
  final bool showBackButton;
  final VoidCallback? onBack;

  const WebPageLayout({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.actions,
    this.padding,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveUtils.isWebLayout(context)) {
      return child;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: padding ?? ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || actions != null) _buildHeader(context),
          if (title != null || actions != null) const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (showBackButton) ...[
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              fixedSize: const Size.square(48),
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (title != null) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: ResponsiveUtils.getFontSize(context, 28),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (actions != null) ...[
          const SizedBox(width: 12),
          ...actions!,
        ],
      ],
    );
  }
}

class WebCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool interactive;
  final VoidCallback? onTap;

  const WebCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.interactive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding = padding ?? ResponsiveUtils.getCardPadding(context);
    final cardBorderRadius = borderRadius ?? 
        BorderRadius.circular(ResponsiveUtils.getCardBorderRadius(context));

    Widget cardChild = Container(
      padding: cardPadding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.background,
        borderRadius: cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.withOpacity(AppColors.black, 0.08),
            blurRadius: elevation ?? 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: child,
    );

    if (interactive && onTap != null) {
      cardChild = InkWell(
        onTap: onTap,
        borderRadius: cardBorderRadius,
        child: cardChild,
      );
    }

    return cardChild;
  }
}

class WebGrid extends StatelessWidget {
  final List<Widget> children;
  final int? crossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double? childAspectRatio;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const WebGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final columns = crossAxisCount ?? ResponsiveUtils.getGridColumnsForCards(context);
    final spacing = ResponsiveUtils.getWebCardSpacing(context);

    return GridView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: mainAxisSpacing ?? spacing,
        crossAxisSpacing: crossAxisSpacing ?? spacing,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

class WebSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final double? width;
  final double? height;

  const WebSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.onClear,
    this.width,
    this.height,
  });

  @override
  State<WebSearchBar> createState() => _WebSearchBarState();
}

class _WebSearchBarState extends State<WebSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? 280,
      height: widget.height ?? 48,
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                  onPressed: () {
                    widget.controller.clear();
                    if (widget.onClear != null) widget.onClear!();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        style: TextStyle(fontSize: 14),
        onChanged: (value) {
          setState(() {});
          if (widget.onChanged != null) widget.onChanged!(value);
        },
      ),
    );
  }
}

class WebActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final bool isPrimary;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;

  const WebActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = true,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? AppColors.primary,
                foregroundColor: foregroundColor ?? AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: foregroundColor ?? AppColors.textPrimary,
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 18),
                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
    );
  }
}

class WebStatsGrid extends StatelessWidget {
  final List<WebStatCard> stats;
  final int? crossAxisCount;
  final EdgeInsets? padding;

  const WebStatsGrid({
    super.key,
    required this.stats,
    this.crossAxisCount,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final columns = crossAxisCount ?? (ResponsiveUtils.isLargeDesktop(context) ? 5 : 
        ResponsiveUtils.isDesktop(context) ? 4 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.0,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => stats[index],
    );
  }
}

class WebStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const WebStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WebCard(
      interactive: onTap != null,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color ?? AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}