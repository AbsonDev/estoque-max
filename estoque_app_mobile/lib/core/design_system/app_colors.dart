import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF667eea);
  static const Color primaryVariant = Color(0xFF764ba2);
  static const Color primaryLight = Color(0xFF9bb5ff);
  static const Color primaryDark = Color(0xFF4c63d2);
  
  static const Color secondary = Color(0xFFf093fb);
  static const Color secondaryVariant = Color(0xFFf5576c);
  static const Color secondaryLight = Color(0xFFf8b8ff);
  static const Color secondaryDark = Color(0xFFd16fe8);

  // Semantic Colors
  static const Color success = Color(0xFF10b981);
  static const Color successLight = Color(0xFF34d399);
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFFecfdf5);
  
  static const Color warning = Color(0xFFf59e0b);
  static const Color warningLight = Color(0xFFfbbf24);
  static const Color warningDark = Color(0xFFd97706);
  static const Color warningSurface = Color(0xFFfffbeb);
  
  static const Color error = Color(0xFFf5576c);
  static const Color errorLight = Color(0xFFfb7185);
  static const Color errorDark = Color(0xFFdc2626);
  static const Color errorSurface = Color(0xFFfef2f2);
  
  static const Color info = Color(0xFF3b82f6);
  static const Color infoLight = Color(0xFF60a5fa);
  static const Color infoDark = Color(0xFF2563eb);
  static const Color infoSurface = Color(0xFFeff6ff);

  // Neutral Colors
  static const Color white = Color(0xFFffffff);
  static const Color black = Color(0xFF000000);
  
  static const Color gray50 = Color(0xFFf9fafb);
  static const Color gray100 = Color(0xFFf3f4f6);
  static const Color gray200 = Color(0xFFe5e7eb);
  static const Color gray300 = Color(0xFFd1d5db);
  static const Color gray400 = Color(0xFF9ca3af);
  static const Color gray500 = Color(0xFF6b7280);
  static const Color gray600 = Color(0xFF4b5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1f2937);
  static const Color gray900 = Color(0xFF111827);

  // Surface Colors
  static const Color surface = Color(0xFFfafafa);
  static const Color surfaceVariant = Color(0xFFf5f5f5);
  static const Color background = Color(0xFFffffff);
  static const Color backgroundVariant = Color(0xFFfcfcfc);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF4a5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textPlaceholder = Color(0xFF9ca3af);
  static const Color textDisabled = Color(0xFFa0aec0);
  static const Color textInverse = Color(0xFFffffff);

  // Border Colors
  static const Color border = Color(0xFFe2e8f0);
  static const Color borderLight = Color(0xFFf1f5f9);
  static const Color borderDark = Color(0xFFcbd5e0);
  static const Color borderFocus = Color(0xFF667eea);
  static const Color borderError = Color(0xFFf5576c);
  static const Color borderSuccess = Color(0xFF10b981);
  static const Color borderWarning = Color(0xFFf59e0b);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  static const Color overlayDark = Color(0xA0000000);
  static const Color scrim = Color(0x66000000);

  // Status Colors
  static const Color online = Color(0xFF10b981);
  static const Color offline = Color(0xFF6b7280);
  static const Color busy = Color(0xFFf59e0b);
  static const Color away = Color(0xFFf59e0b);

  // Special Colors
  static const Color highlight = Color(0xFFfef3c7);
  static const Color selection = Color(0xFFbfdbfe);
  static const Color focus = Color(0xFF3b82f6);
  static const Color disabled = Color(0xFFf3f4f6);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF667eea),
    Color(0xFFf093fb),
    Color(0xFF10b981),
    Color(0xFFf59e0b),
    Color(0xFFf5576c),
    Color(0xFF3b82f6),
    Color(0xFF8b5cf6),
    Color(0xFFef4444),
    Color(0xFF06b6d4),
    Color(0xFFf97316),
  ];

  // Gradient Variants
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, warningDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient infoGradient = LinearGradient(
    colors: [info, infoDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, backgroundVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFe2e8f0);
  static const Color shimmerHighlight = Color(0xFFf1f5f9);

  // Dark Theme Colors (for future use)
  static const Color darkSurface = Color(0xFF1a202c);
  static const Color darkBackground = Color(0xFF2d3748);
  static const Color darkTextPrimary = Color(0xFFf7fafc);
  static const Color darkTextSecondary = Color(0xFFe2e8f0);
  static const Color darkBorder = Color(0xFF4a5568);

  // Helper methods
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static Color darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  static Color blend(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio) ?? color1;
  }
}