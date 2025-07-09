import 'package:flutter/material.dart';
import '../responsive/responsive_utils.dart';
import '../design_system/design_tokens.dart';
import '../design_system/app_colors.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final Widget? sidebar;
  final bool showSidebar;
  final bool showBottomNavigation;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final List<Widget>? persistentFooterButtons;
  final bool resizeToAvoidBottomInset;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.sidebar,
    this.showSidebar = true,
    this.showBottomNavigation = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.backgroundColor,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.persistentFooterButtons,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowSidebar = showSidebar && ResponsiveUtils.shouldShowSidebar(context);
    final shouldShowBottomNav = showBottomNavigation && ResponsiveUtils.shouldShowBottomNavigation(context);
    final shouldShowFab = ResponsiveUtils.shouldShowFab(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: _buildBody(context, shouldShowSidebar),
      bottomNavigationBar: shouldShowBottomNav ? bottomNavigationBar : null,
      floatingActionButton: shouldShowFab ? floatingActionButton : null,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      persistentFooterButtons: persistentFooterButtons,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  Widget _buildBody(BuildContext context, bool shouldShowSidebar) {
    if (shouldShowSidebar && sidebar != null) {
      return Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: _buildMainContent(context),
          ),
        ],
      );
    }
    
    return _buildMainContent(context);
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: ResponsiveUtils.getSidebarWidth(context),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
            blurRadius: 4,
          ),
        ],
      ),
      child: sidebar,
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final padding = ResponsiveUtils.getPagePadding(context);

    return Container(
      width: double.infinity,
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final Color? backgroundColor;
  final List<Widget>? persistentFooterButtons;
  final bool resizeToAvoidBottomInset;
  final bool applySafeArea;
  final bool centerContent;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.backgroundColor,
    this.persistentFooterButtons,
    this.resizeToAvoidBottomInset = true,
    this.applySafeArea = true,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: _buildBody(context),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      persistentFooterButtons: persistentFooterButtons,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  Widget _buildBody(BuildContext context) {
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final padding = ResponsiveUtils.getPagePadding(context);

    Widget content = Container(
      width: double.infinity,
      padding: padding,
      child: centerContent 
          ? Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: body,
              ),
            )
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              child: body,
            ),
    );

    if (applySafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Color? color;
  final Decoration? decoration;
  final bool constrainWidth;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.color,
    this.decoration,
    this.constrainWidth = true,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveUtils.getPagePadding(context);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    Widget content = Container(
      width: width,
      height: height,
      padding: responsivePadding,
      margin: margin,
      alignment: alignment,
      color: color,
      decoration: decoration,
      child: child,
    );

    if (constrainWidth) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: content,
      );
    }

    if (centerContent) {
      content = Center(child: content);
    }

    return content;
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? crossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double? childAspectRatio;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool useCards;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.useCards = false,
  });

  @override
  Widget build(BuildContext context) {
    final columns = crossAxisCount ?? ResponsiveUtils.getGridColumnsForCards(context);
    final spacing = ResponsiveUtils.valueByScreen(
      context,
      mobile: DesignTokens.spacing12,
      tablet: DesignTokens.spacing16,
      desktop: DesignTokens.spacing20,
    );

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? ResponsiveUtils.getPagePadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: mainAxisSpacing ?? spacing,
        crossAxisSpacing: crossAxisSpacing ?? spacing,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        Widget child = children[index];
        
        if (useCards) {
          child = Card(
            child: child,
          );
        }
        
        return child;
      },
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool wrapOnMobile;
  final double? spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.wrapOnMobile = false,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final shouldWrap = wrapOnMobile && ResponsiveUtils.isMobile(context);
    
    if (shouldWrap) {
      return Wrap(
        spacing: spacing ?? DesignTokens.spacing12,
        runSpacing: spacing ?? DesignTokens.spacing12,
        children: children,
      );
    }
    
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _addSpacing(children, spacing),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double? spacing) {
    if (spacing == null || children.isEmpty) return children;
    
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }
    return spacedChildren;
  }
}

class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? spacing;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _addSpacing(children, spacing),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double? spacing) {
    if (spacing == null || children.isEmpty) return children;
    
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }
    return spacedChildren;
  }
}