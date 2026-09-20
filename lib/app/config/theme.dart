import 'package:flutter/material.dart';

class AppColors {
  // Dark OLED Palette (RichMan Style)
  static const Color background = Color(0xFF0D0F12);
  static const Color surface = Color(0xFF161A20);
  static const Color surfaceVariant = Color(0xFF202630);
  
  // Accents
  static const Color primary = Color(0xFF00E676); // Money Green
  static const Color primaryLight = Color(0xFF69F0AE);
  static const Color secondary = Color(0xFF2979FF); // Tech Blue
  static const Color warning = Color(0xFFFFAB00); // Gold / Attention
  static const Color danger = Color(0xFFFF5252); // Red / Maintenance / Down
  
  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF90A4AE);
  static const Color textMuted = Color(0xFF546E7A);
  
  // Borders & Dividers
  static const Color border = Color(0xFF263238);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
