import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF12284C);
  static const navyDeep = Color(0xFF0B1A33);
  static const gold = Color(0xFFC9A24A);
  static const cream = Color(0xFFF6F3EC);
  static const ink = Color(0xFF101A2E);
}

class AppTheme {
  static const _heading = 'PlayfairDisplay';
  static const _body = 'Manrope';

  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;

    final scheme =
        ColorScheme.fromSeed(seedColor: AppColors.navy, brightness: b).copyWith(
          primary: isDark ? AppColors.gold : AppColors.navy,
          onPrimary: isDark ? AppColors.navyDeep : Colors.white,
          secondary: AppColors.gold,
          onSecondary: AppColors.navyDeep,
          surface: isDark ? const Color(0xFF111F38) : Colors.white,
          onSurface: isDark ? const Color(0xFFE9EDF5) : AppColors.ink,
          primaryContainer: isDark
              ? const Color(0xFF1D3358)
              : const Color(0xFFE3E9F5),
          onPrimaryContainer: isDark ? const Color(0xFFE9EDF5) : AppColors.navy,
          surfaceContainerHighest: isDark
              ? const Color(0xFF1A2D4D)
              : const Color(0xFFEFEBE0),
          outlineVariant: isDark
              ? const Color(0xFF2A3F63)
              : const Color(0xFFDDD6C5),
          // disclaimer cards ab halka amber (laal nahi)
          errorContainer: isDark
              ? const Color(0xFF3A2F12)
              : const Color(0xFFFFF3D6),
          onErrorContainer: isDark
              ? const Color(0xFFFFE7A8)
              : const Color(0xFF5A4300),
        );

    final baseText = ThemeData(brightness: b, useMaterial3: true).textTheme
        .apply(
          fontFamily: _body,
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );

    TextStyle? heading(TextStyle? s) => s?.copyWith(
      fontFamily: _heading,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    );

    final text = baseText.copyWith(
      displayLarge: heading(baseText.displayLarge),
      displayMedium: heading(baseText.displayMedium),
      displaySmall: heading(baseText.displaySmall),
      headlineLarge: heading(baseText.headlineLarge),
      headlineMedium: heading(baseText.headlineMedium),
      headlineSmall: heading(baseText.headlineSmall),
      titleLarge: heading(baseText.titleLarge),
    );

    final scaffoldBg = isDark ? AppColors.navyDeep : AppColors.cream;
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: _body,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _heading,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: const TextStyle(
            fontFamily: _body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        checkmarkColor: scheme.primary,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
