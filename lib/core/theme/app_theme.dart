import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.leather,
      brightness: brightness,
      primary: isLight ? AppColors.leather : AppColors.gold,
      secondary: isLight ? AppColors.olive : AppColors.olive,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? AppColors.cream : AppColors.night,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.leather : AppColors.night,
        foregroundColor: isLight ? AppColors.cream : AppColors.gold,
        centerTitle: true,
      ),
    );
  }
}