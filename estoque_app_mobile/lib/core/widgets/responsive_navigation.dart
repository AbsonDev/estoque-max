import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../design_system/design_tokens.dart';
import '../responsive/responsive_utils.dart';
import '../animations/app_animations.dart';

class ResponsiveNavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final VoidCallback? onTap;
  final bool isActive;
  final Widget? badge;
  final Color? color;
  final List<ResponsiveNavigationItem>? children;

  const ResponsiveNavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    this.activeIcon,
    this.onTap,
    this.isActive = false,
    this.badge,
    this.color,
    this.children,
  });

  ResponsiveNavigationItem copyWith({
    String? id,
    String? label,
    IconData? icon,
    IconData? activeIcon,
    VoidCallback? onTap,
    bool? isActive,
    Widget? badge,
    Color? color,
    List<ResponsiveNavigationItem>? children,
  }) {
    return ResponsiveNavigationItem(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      onTap: onTap ?? this.onTap,
      isActive: isActive ?? this.isActive,
      badge: badge ?? this.badge,
      color: color ?? this.color,
      children: children ?? this.children,
    );
  }
}

class ResponsiveNavigationSidebar extends StatelessWidget {
  final List<ResponsiveNavigationItem> items;
  final Widget? header;
  final Widget? footer;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? width;

  const ResponsiveNavigationSidebar({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.padding,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = width ?? ResponsiveUtils.getSidebarWidth(context);
    final collapsedWidth = ResponsiveUtils.valueByScreen(
      context,
      mobile: 0.0,
      tablet: 0.0,
      desktop: 80.0,
    );

    return AnimatedContainer(
      duration: DesignTokens.animationMedium,
      width: isCollapsed ? collapsedWidth : sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.withOpacity(AppColors.black, 0.05),
            offset: const Offset(2, 0),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          if (header != null) ...[
            AnimatedContainer(
              duration: DesignTokens.animationMedium,
              padding: padding ?? ResponsiveUtils.getCardPadding(context),
              child: header!,
            ),
            const Divider(),
          ],
          Expanded(
            child: ListView.builder(
              padding: padding ?? ResponsiveUtils.getCardPadding(context),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildSidebarItem(context, items[index], index);
              },
            ),
          ),
          if (footer != null) ...[
            const Divider(),
            AnimatedContainer(
              duration: DesignTokens.animationMedium,
              padding: padding ?? ResponsiveUtils.getCardPadding(context),
              child: footer!,
            ),
          ],
          if (onToggleCollapse != null)
            _buildCollapseButton(context),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, ResponsiveNavigationItem item, int index) {
    final iconSize = ResponsiveUtils.getIconSize(context, DesignTokens.iconMedium);
    final isActive = item.isActive;
    final itemColor = isActive ? AppColors.primary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getCardBorderRadius(context)),
          child: AnimatedContainer(
            duration: DesignTokens.animationMedium,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing16,
              vertical: DesignTokens.spacing12,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.withOpacity(AppColors.primary, 0.1) : null,
              borderRadius: BorderRadius.circular(ResponsiveUtils.getCardBorderRadius(context)),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isActive ? (item.activeIcon ?? item.icon) : item.icon,
                      color: itemColor,
                      size: iconSize,
                    ),
                    if (item.badge != null)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: item.badge!,
                      ),
                  ],
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: DesignTokens.spacing12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: itemColor,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate(effects: AppAnimations.staggeredListAnimation(
      index: index,
      duration: const Duration(milliseconds: 200),
    ));
  }

  Widget _buildCollapseButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing8),
      child: IconButton(
        onPressed: onToggleCollapse,
        icon: AnimatedRotation(
          duration: DesignTokens.animationMedium,
          turns: isCollapsed ? 0.5 : 0,
          child: Icon(
            Icons.chevron_left,
            color: AppColors.textSecondary,
          ),
        ),
        tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
      ),
    );
  }
}

class ResponsiveBottomNavigation extends StatelessWidget {
  final List<ResponsiveNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final double? height;
  final bool showLabels;

  const ResponsiveBottomNavigation({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.height,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final navHeight = height ?? ResponsiveUtils.getBottomNavigationHeight(context);
    
    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.withOpacity(AppColors.black, 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Expanded(
              child: _buildBottomNavItem(context, item, index),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, ResponsiveNavigationItem item, int index) {
    final isActive = index == currentIndex;
    final iconSize = ResponsiveUtils.getIconSize(context, DesignTokens.iconMedium);
    final itemColor = isActive ? AppColors.primary : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) onTap!(index);
          item.onTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing8,
            vertical: DesignTokens.spacing8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: DesignTokens.animationMedium,
                    child: Icon(
                      isActive ? (item.activeIcon ?? item.icon) : item.icon,
                      color: itemColor,
                      size: iconSize,
                    ),
                  ),
                  if (item.badge != null)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: item.badge!,
                    ),
                ],
              ),
              if (showLabels) ...[
                const SizedBox(height: DesignTokens.spacing4),
                AnimatedDefaultTextStyle(
                  duration: DesignTokens.animationMedium,
                  style: AppTypography.navigationLabel(context).copyWith(
                    color: itemColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ResponsiveNavigationRail extends StatelessWidget {
  final List<ResponsiveNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Widget? header;
  final Widget? footer;
  final bool extended;
  final Color? backgroundColor;
  final double? width;

  const ResponsiveNavigationRail({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.header,
    this.footer,
    this.extended = false,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      backgroundColor: backgroundColor ?? AppColors.surface,
      selectedIndex: currentIndex,
      onDestinationSelected: (int index) {
        if (onTap != null) onTap!(index);
        items[index].onTap?.call();
      },
      leading: header,
      trailing: footer,
      destinations: items.asMap().entries.map((entry) {
        final item = entry.value;
        return NavigationRailDestination(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.icon),
              if (item.badge != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: item.badge!,
                ),
            ],
          ),
          selectedIcon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.activeIcon ?? item.icon),
              if (item.badge != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: item.badge!,
                ),
            ],
          ),
          label: Text(item.label),
        );
      }).toList(),
    );
  }
}

class ResponsiveNavigationWrapper extends StatelessWidget {
  final List<ResponsiveNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final Widget child;

  const ResponsiveNavigationWrapper({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.sidebarHeader,
    this.sidebarFooter,
    this.isCollapsed = false,
    this.onToggleCollapse,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowSidebar = ResponsiveUtils.shouldShowSidebar(context);
    final shouldShowBottomNav = ResponsiveUtils.shouldShowBottomNavigation(context);

    return Scaffold(
      body: Row(
        children: [
          if (shouldShowSidebar)
            ResponsiveNavigationSidebar(
              items: items,
              header: sidebarHeader,
              footer: sidebarFooter,
              isCollapsed: isCollapsed,
              onToggleCollapse: onToggleCollapse,
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: shouldShowBottomNav
          ? ResponsiveBottomNavigation(
              items: items,
              currentIndex: currentIndex,
              onTap: onTap,
            )
          : null,
    );
  }
}

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;

  const ResponsiveAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.bottom,
    this.flexibleSpace,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveTitle = titleWidget ?? (title != null 
        ? Text(
            title!,
            style: AppTypography.appBarTitle(context),
          )
        : null);

    return AppBar(
      title: responsiveTitle,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation ?? DesignTokens.elevation0,
      backgroundColor: backgroundColor ?? AppColors.background,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      centerTitle: centerTitle,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

class ResponsiveTabBar extends StatelessWidget {
  final List<ResponsiveNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool isScrollable;
  final EdgeInsets? padding;

  const ResponsiveTabBar({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.isScrollable = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: DesignTokens.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        isScrollable: isScrollable,
        tabs: items.map((item) => Tab(
          icon: Icon(item.icon),
          text: item.label,
        )).toList(),
        onTap: (index) {
          if (onTap != null) onTap!(index);
          items[index].onTap?.call();
        },
      ),
    );
  }
}

class NavigationBadge extends StatelessWidget {
  final String? text;
  final bool showDot;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;

  const NavigationBadge({
    super.key,
    this.text,
    this.showDot = false,
    this.backgroundColor,
    this.textColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final double badgeSize = size ?? ResponsiveUtils.valueByScreen(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );

    if (showDot) {
      return Container(
        width: badgeSize * 0.6,
        height: badgeSize * 0.6,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.error,
          shape: BoxShape.circle,
        ),
      );
    }

    if (text == null) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        minWidth: badgeSize,
        minHeight: badgeSize,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing4,
        vertical: DesignTokens.spacing2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.error,
        borderRadius: BorderRadius.circular(badgeSize / 2),
      ),
      child: Text(
        text!,
        style: AppTypography.labelSmall(context).copyWith(
          color: textColor ?? AppColors.white,
          fontSize: ResponsiveUtils.getFontSize(context, 10),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}