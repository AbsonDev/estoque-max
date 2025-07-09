import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import '../responsive/responsive_utils.dart';

class AppTypography {
  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Line Heights
  static const double lineHeightTight = 1.1;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;

  // Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingExtraWide = 1.0;

  // Display Styles
  static TextStyle display1(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 64),
    fontWeight: extraBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: AppColors.textPrimary,
  );

  static TextStyle display2(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 48),
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: AppColors.textPrimary,
  );

  static TextStyle display3(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 36),
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: AppColors.textPrimary,
  );

  // Headline Styles
  static TextStyle headline1(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 32),
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: AppColors.textPrimary,
  );

  static TextStyle headline2(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 28),
    fontWeight: bold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle headline3(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 24),
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle headline4(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 20),
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle headline5(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 18),
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle headline6(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 16),
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  // Body Styles
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 16),
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 14),
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textSecondary,
  );

  // Label Styles
  static TextStyle labelLarge(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 14),
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: AppColors.textPrimary,
  );

  static TextStyle labelSmall(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 10),
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingExtraWide,
    color: AppColors.textSecondary,
  );

  // Caption Styles
  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 10),
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textTertiary,
  );

  static TextStyle overline(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 8),
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingExtraWide,
    color: AppColors.textTertiary,
  );

  // Button Styles
  static TextStyle buttonLarge(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 16),
    fontWeight: semiBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
    color: AppColors.white,
  );

  static TextStyle buttonMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 14),
    fontWeight: semiBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
    color: AppColors.white,
  );

  static TextStyle buttonSmall(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: semiBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingWide,
    color: AppColors.white,
  );

  // Input Styles
  static TextStyle inputLabel(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 14),
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textSecondary,
  );

  static TextStyle inputText(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 16),
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle inputHint(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 16),
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPlaceholder,
  );

  static TextStyle inputError(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.error,
  );

  // Navigation Styles
  static TextStyle navigationLabel(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textSecondary,
  );

  static TextStyle navigationLabelActive(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.primary,
  );

  // AppBar Styles
  static TextStyle appBarTitle(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 20),
    fontWeight: semiBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle appBarSubtitle(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 14),
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textSecondary,
  );

  // Card Styles
  static TextStyle cardTitle(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 16),
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle cardSubtitle(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 14),
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textSecondary,
  );

  static TextStyle cardContent(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: AppColors.textTertiary,
  );

  // Status Styles
  static TextStyle statusSuccess(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.success,
  );

  static TextStyle statusWarning(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.warning,
  );

  static TextStyle statusError(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.error,
  );

  static TextStyle statusInfo(BuildContext context) => GoogleFonts.inter(
    fontSize: ResponsiveUtils.getFontSize(context, 12),
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: AppColors.info,
  );

  // Utility Methods
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  static TextStyle withLetterSpacing(TextStyle style, double letterSpacing) {
    return style.copyWith(letterSpacing: letterSpacing);
  }

  static TextStyle withDecoration(TextStyle style, TextDecoration decoration) {
    return style.copyWith(decoration: decoration);
  }

  static TextStyle withShadow(TextStyle style, List<Shadow> shadows) {
    return style.copyWith(shadows: shadows);
  }

  // Theme Integration
  static TextTheme getTextTheme(BuildContext context) {
    return TextTheme(
      displayLarge: display1(context),
      displayMedium: display2(context),
      displaySmall: display3(context),
      headlineLarge: headline1(context),
      headlineMedium: headline2(context),
      headlineSmall: headline3(context),
      titleLarge: headline4(context),
      titleMedium: headline5(context),
      titleSmall: headline6(context),
      bodyLarge: bodyLarge(context),
      bodyMedium: bodyMedium(context),
      bodySmall: bodySmall(context),
      labelLarge: labelLarge(context),
      labelMedium: labelMedium(context),
      labelSmall: labelSmall(context),
    );
  }
}