import 'package:flutter/material.dart';

enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

class ResponsiveUtils {
  static const double _mobileBreakpoint = 768;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < _mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < _tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < _desktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  static bool isMobile(BuildContext context) => getScreenType(context) == ScreenType.mobile;
  static bool isTablet(BuildContext context) => getScreenType(context) == ScreenType.tablet;
  static bool isDesktop(BuildContext context) => getScreenType(context) == ScreenType.desktop;
  static bool isLargeDesktop(BuildContext context) => getScreenType(context) == ScreenType.largeDesktop;

  static bool isSmallScreen(BuildContext context) => 
      getScreenType(context) == ScreenType.mobile;
  
  static bool isMediumScreen(BuildContext context) => 
      getScreenType(context) == ScreenType.tablet;
  
  static bool isLargeScreen(BuildContext context) => 
      getScreenType(context) == ScreenType.desktop || 
      getScreenType(context) == ScreenType.largeDesktop;

  static double getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double getScreenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static int getGridColumns(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.desktop:
        return 3;
      case ScreenType.largeDesktop:
        return 4;
    }
  }

  static int getGridColumnsForCards(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return 2;
      case ScreenType.tablet:
        return 3;
      case ScreenType.desktop:
        return 4;
      case ScreenType.largeDesktop:
        return 5;
    }
  }

  static EdgeInsets getPagePadding(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16);
      case ScreenType.tablet:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 20);
      case ScreenType.desktop:
        return const EdgeInsets.symmetric(horizontal: 36, vertical: 24);
      case ScreenType.largeDesktop:
        return const EdgeInsets.symmetric(horizontal: 48, vertical: 28);
    }
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return const EdgeInsets.all(12);
      case ScreenType.tablet:
        return const EdgeInsets.all(16);
      case ScreenType.desktop:
        return const EdgeInsets.all(20);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(24);
    }
  }

  static double getCardBorderRadius(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return 12;
      case ScreenType.tablet:
        return 16;
      case ScreenType.desktop:
        return 20;
      case ScreenType.largeDesktop:
        return 24;
    }
  }

  static double getBottomNavigationHeight(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return 65;
      case ScreenType.tablet:
        return 70;
      case ScreenType.desktop:
        return 0; // No bottom navigation on desktop
      case ScreenType.largeDesktop:
        return 0; // No bottom navigation on large desktop
    }
  }

  static double getSidebarWidth(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return 0; // No sidebar on mobile
      case ScreenType.tablet:
        return 0; // No sidebar on tablet
      case ScreenType.desktop:
        return 320;
      case ScreenType.largeDesktop:
        return 360;
    }
  }

  static double getMaxContentWidth(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return double.infinity;
      case ScreenType.tablet:
        return 768;
      case ScreenType.desktop:
        return 1200;
      case ScreenType.largeDesktop:
        return 1600;
    }
  }

  static double getDialogWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return screenWidth * 0.9;
      case ScreenType.tablet:
        return screenWidth * 0.7;
      case ScreenType.desktop:
        return screenWidth * 0.5;
      case ScreenType.largeDesktop:
        return screenWidth * 0.4;
    }
  }

  static T valueByScreen<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  static double getFontSize(BuildContext context, double baseFontSize) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return baseFontSize;
      case ScreenType.tablet:
        return baseFontSize * 1.1;
      case ScreenType.desktop:
        return baseFontSize * 1.2;
      case ScreenType.largeDesktop:
        return baseFontSize * 1.3;
    }
  }

  static double getIconSize(BuildContext context, double baseIconSize) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return baseIconSize;
      case ScreenType.tablet:
        return baseIconSize * 1.1;
      case ScreenType.desktop:
        return baseIconSize * 1.2;
      case ScreenType.largeDesktop:
        return baseIconSize * 1.3;
    }
  }

  static bool shouldShowSidebar(BuildContext context) {
    return isDesktop(context) || isLargeDesktop(context);
  }

  static bool shouldShowBottomNavigation(BuildContext context) {
    return isMobile(context) || isTablet(context);
  }

  static bool shouldShowFab(BuildContext context) {
    return isMobile(context) || isTablet(context);
  }

  static bool isWebLayout(BuildContext context) {
    return isDesktop(context) || isLargeDesktop(context);
  }

  static double getWebContentSpacing(BuildContext context) {
    return isWebLayout(context) ? 20.0 : 16.0;
  }

  static double getWebCardSpacing(BuildContext context) {
    return isWebLayout(context) ? 16.0 : 12.0;
  }

  static double getCompactSpacing(BuildContext context) {
    return isWebLayout(context) ? 12.0 : 8.0;
  }

  static EdgeInsets getCompactPadding(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return const EdgeInsets.all(12);
      case ScreenType.tablet:
        return const EdgeInsets.all(16);
      case ScreenType.desktop:
        return const EdgeInsets.all(20);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(24);
    }
  }

  static CrossAxisAlignment getMainAxisAlignment(BuildContext context) {
    return isLargeScreen(context) 
        ? CrossAxisAlignment.start 
        : CrossAxisAlignment.center;
  }

  static MainAxisAlignment getCrossAxisAlignment(BuildContext context) {
    return isLargeScreen(context) 
        ? MainAxisAlignment.start 
        : MainAxisAlignment.center;
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.valueByScreen(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveUtils.getScreenType(context));
  }
}