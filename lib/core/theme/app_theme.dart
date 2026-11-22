import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _serif = 'PlayfairDisplay';
  static const _sans = 'Lato';

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static TextStyle? _s(TextStyle? style) => style?.copyWith(fontFamily: _serif);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.leather,
      brightness: brightness,
      primary: isLight ? AppColors.leather : AppColors.gold,
      secondary: AppColors.olive,
      surface: isLight ? AppColors.cream : AppColors.night,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: _sans,
    );

    final t = base.textTheme;
    final textTheme = t.copyWith(
      displayLarge: _s(t.displayLarge),
      displayMedium: _s(t.displayMedium),
      displaySmall: _s(t.displaySmall),
      headlineLarge: _s(t.headlineLarge),
      headlineMedium: _s(t.headlineMedium),
      headlineSmall: _s(t.headlineSmall),
      titleLarge: _s(t.titleLarge),
    );

    final appBarFg = isLight ? AppColors.cream : AppColors.gold;

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: isLight ? AppColors.cream : AppColors.night,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.leather : AppColors.night,
        foregroundColor: appBarFg,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _serif,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: appBarFg,
        ),
      ),
      cardTheme: CardThemeData(
        color: isLight ? AppColors.parchment : AppColors.nightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}