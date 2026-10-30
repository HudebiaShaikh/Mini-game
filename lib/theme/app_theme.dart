import 'package:flutter/material.dart';

/// All the colours used in the app, for light mode and dark mode.
class AppColors {
  final Color primary;
  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color onPrimary;
  final Color shadow;

  const AppColors({
    required this.primary,
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.onPrimary,
    required this.shadow,
  });

  static const light = AppColors(
    primary: Color(0xFFD1A3AA),
    background: Color(0xFFF8EEEE),
    surface: Color(0xFFF3E3E4),
    card: Color(0xFFE9CFD2),
    border: Color(0xFFB07B7F),
    accent: Color(0xFFB07B7F),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF6E3F45),
    onPrimary: Color(0xFF000000),
    shadow: Color(0xFF8C5A60),
  );

  static const dark = AppColors(
    primary: Color(0xFFB07B7F),
    background: Color(0xFF150E0F),
    surface: Color(0xFF1F1416),
    card: Color(0xFF2A1B1E),
    border: Color(0xFFB07B7F),
    accent: Color(0xFFD1A3AA),
    textPrimary: Color(0xFFF6ECED),
    textSecondary: Color(0xFFD1A3AA),
    onPrimary: Color(0xFFFFFFFF),
    shadow: Color(0xFF000000),
  );

  /// Returns the colours that match the current light/dark mode.
  static AppColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? dark : light;
  }
}

/// Builds the Material themes from [AppColors].
class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.primary,
        brightness: brightness,
        primary: c.primary,
        surface: c.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        centerTitle: true,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
