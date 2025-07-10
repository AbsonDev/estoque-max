import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../design_system/design_tokens.dart';
import '../responsive/responsive_utils.dart';

class AppTheme {
  // Legacy color references for backwards compatibility
  static const Color primaryColor = AppColors.primary;
  static const Color primaryVariant = AppColors.primaryVariant;
  static const Color secondary = AppColors.secondary;
  static const Color secondaryVariant = AppColors.secondaryVariant;
  static const Color surface = AppColors.surface;
  static const Color background = AppColors.background;
  static const Color error = AppColors.error;
  static const Color onPrimary = AppColors.white;
  static const Color onSecondary = AppColors.white;
  static const Color onSurface = AppColors.textPrimary;
  static const Color onBackground = AppColors.textPrimary;
  static const Color onError = AppColors.white;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textHint = AppColors.textPlaceholder;
  static const Color divider = AppColors.border;
  static const Color inputBorder = AppColors.border;
  static const Color inputFocus = AppColors.borderFocus;
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;

  static ThemeData getLightTheme(BuildContext context) => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      outline: AppColors.border,
      outlineVariant: AppColors.borderLight,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,
      inverseSurface: AppColors.gray800,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.primaryLight,
      tertiary: AppColors.info,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.infoSurface,
      onTertiaryContainer: AppColors.infoDark,
    ),
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surface,
    textTheme: AppTypography.getTextTheme(context),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: DesignTokens.elevation0,
      centerTitle: true,
      titleTextStyle: AppTypography.appBarTitle(context),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      actionsIconTheme: const IconThemeData(color: AppColors.textPrimary),
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.withOpacity(AppColors.black, 0.1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: DesignTokens.elevation2,
        shadowColor: AppColors.withOpacity(AppColors.primary, 0.3),
        padding: ResponsiveUtils.valueByScreen(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          tablet: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          desktop: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getCardBorderRadius(context),
          ),
        ),
        textStyle: AppTypography.buttonMedium(context).copyWith(
          color: AppColors.white, // Força cor branca no texto
          fontWeight: FontWeight.w600,
        ),
        minimumSize: Size(0, DesignTokens.buttonHeightMedium),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        elevation: DesignTokens.elevation0,
        padding: ResponsiveUtils.valueByScreen(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          tablet: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          desktop: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getCardBorderRadius(context),
          ),
        ),
        textStyle: AppTypography.buttonMedium(context).copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        minimumSize: Size(0, DesignTokens.buttonHeightMedium),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: ResponsiveUtils.valueByScreen(
        context,
        mobile: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        desktop: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardBorderRadius(context),
        ),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardBorderRadius(context),
        ),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardBorderRadius(context),
        ),
        borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardBorderRadius(context),
        ),
        borderSide: const BorderSide(color: AppColors.borderError, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardBorderRadius(context),
        ),
        borderSide: const BorderSide(color: AppColors.borderError, width: 2),
      ),
      labelStyle: AppTypography.inputLabel(context),
      hintStyle: AppTypography.inputHint(context),
      errorStyle: AppTypography.inputError(context),
      floatingLabelStyle: AppTypography.inputLabel(
        context,
      ).copyWith(color: AppColors.primary),
      suffixIconColor: AppColors.textSecondary,
      prefixIconColor: AppColors.textSecondary,
    ),
    cardTheme: CardThemeData(
      elevation: DesignTokens.elevation2,
      shadowColor: AppColors.withOpacity(AppColors.black, 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getCardBorderRadius(context),
        ),
      ),
      color: AppColors.background,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
      indent: 0,
      endIndent: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: DesignTokens.elevation8,
      selectedLabelStyle: AppTypography.navigationLabelActive(context),
      unselectedLabelStyle: AppTypography.navigationLabel(context),
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // Additional theme configurations
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.gray300;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected))
          return AppColors.primaryLight;
        return AppColors.gray200;
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.surface;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
      overlayColor: WidgetStateProperty.all(
        AppColors.withOpacity(AppColors.primary, 0.12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall / 2),
      ),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.textSecondary;
      }),
      overlayColor: WidgetStateProperty.all(
        AppColors.withOpacity(AppColors.primary, 0.12),
      ),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.gray200,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.withOpacity(AppColors.primary, 0.12),
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: AppTypography.labelSmall(
        context,
      ).copyWith(color: AppColors.white),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.gray200,
      circularTrackColor: AppColors.gray200,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      disabledColor: AppColors.disabled,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing12,
        vertical: DesignTokens.spacing8,
      ),
      labelStyle: AppTypography.labelMedium(context),
      secondaryLabelStyle: AppTypography.labelMedium(
        context,
      ).copyWith(color: AppColors.white),
      brightness: Brightness.light,
      elevation: DesignTokens.elevation1,
      pressElevation: DesignTokens.elevation2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: DesignTokens.elevation4,
      focusElevation: DesignTokens.elevation8,
      hoverElevation: DesignTokens.elevation8,
      highlightElevation: DesignTokens.elevation12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.gray800,
      contentTextStyle: AppTypography.bodyMedium(
        context,
      ).copyWith(color: AppColors.white),
      actionTextColor: AppColors.primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: DesignTokens.elevation8,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.background,
      elevation: DesignTokens.elevation24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      titleTextStyle: AppTypography.headline5(context),
      contentTextStyle: AppTypography.bodyMedium(context),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.background,
      elevation: DesignTokens.elevation16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLarge),
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.gray800,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      textStyle: AppTypography.bodySmall(
        context,
      ).copyWith(color: AppColors.white),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing12,
        vertical: DesignTokens.spacing8,
      ),
    ),

    listTileTheme: ListTileThemeData(
      contentPadding: ResponsiveUtils.valueByScreen(
        context,
        mobile: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing16,
          vertical: DesignTokens.spacing8,
        ),
        tablet: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing20,
          vertical: DesignTokens.spacing12,
        ),
        desktop: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing24,
          vertical: DesignTokens.spacing16,
        ),
      ),
      titleTextStyle: AppTypography.bodyLarge(context),
      subtitleTextStyle: AppTypography.bodyMedium(context),
      leadingAndTrailingTextStyle: AppTypography.labelMedium(context),
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
      tileColor: AppColors.surface,
      selectedTileColor: AppColors.withOpacity(AppColors.primary, 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTypography.labelLarge(context),
      unselectedLabelStyle: AppTypography.labelLarge(context),
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 2.0),
        ),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: AppColors.border,
      overlayColor: WidgetStateProperty.all(
        AppColors.withOpacity(AppColors.primary, 0.12),
      ),
    ),
  );

  // Static theme for cases where context is not available
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(),
  );

  // Helper methods for theme access
  static ColorScheme colorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  static TextTheme textTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }
}
