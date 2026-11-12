import 'package:flutter/material.dart';

class AppColors {
  static const canvas = Color(0xFF0B111E);
  static const sidebar = Color(0xFF111A2E);
  static const card = Color(0xFF182238);
  static const elevated = Color(0xFF1E2B45);
  static const amber = Color(0xFFE5A93C);
  static const amberHover = Color(0xFFF3BA54);
  static const cobalt = Color(0xFF3B82F6);
  static const text = Color(0xFFE6ECFA);
  static const muted = Color(0xFF94A3B8);
  static const faint = Color(0xFF64748B);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const hairline = Color(0x14FFFFFF); // 8% safed
  static const line = Color(0x1AFFFFFF); // 10% safed

  // purane naam (agar kisi file mein reh gaye hon)
  static const gold = amber;
  static const navy = sidebar;
  static const navyDeep = canvas;
}

class AppTheme {
  static const _head = 'Outfit';
  static const _body = 'PlusJakartaSans';
  static const _mono = 'JetBrainsMono';

  /// Citations, badges aur numbers ke liye
  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) => TextStyle(
    fontFamily: _mono,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: 0.4,
    color: color ?? AppColors.amberHover,
  );

  static TextStyle _h(double size, FontWeight w, {double ls = -0.3}) =>
      TextStyle(
        fontFamily: _head,
        fontSize: size,
        fontWeight: w,
        letterSpacing: ls,
        height: 1.2,
        color: AppColors.text,
      );

  static TextStyle _b(
    double size,
    FontWeight w, {
    Color color = AppColors.text,
    double ls = 0,
  }) => TextStyle(
    fontFamily: _body,
    fontSize: size,
    fontWeight: w,
    letterSpacing: ls,
    height: 1.5,
    color: color,
  );

  static final dark = _build();

  static ThemeData _build() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.amber,
      onPrimary: AppColors.canvas,
      primaryContainer: Color(0xFF3A2D12),
      onPrimaryContainer: AppColors.amberHover,
      secondary: AppColors.cobalt,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.elevated,
      onSecondaryContainer: Colors.white,
      tertiary: AppColors.success,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: Color(0xFF2B2412),
      onErrorContainer: Color(0xFFF3C77A),
      surface: AppColors.sidebar,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.muted,
      outline: Color(0x33FFFFFF),
      outlineVariant: AppColors.hairline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.text,
      onInverseSurface: AppColors.canvas,
      inversePrimary: Color(0xFF7E5700),
      surfaceContainerLowest: AppColors.canvas,
      surfaceContainerLow: AppColors.sidebar,
      surfaceContainer: AppColors.card,
      surfaceContainerHigh: AppColors.elevated,
      surfaceContainerHighest: Color(0xFF243352),
    );

    final text = TextTheme(
      displayLarge: _h(48, FontWeight.w600, ls: -1.2),
      displayMedium: _h(40, FontWeight.w600, ls: -1),
      displaySmall: _h(34, FontWeight.w600),
      headlineLarge: _h(32, FontWeight.w600, ls: -0.6),
      headlineMedium: _h(28, FontWeight.w600, ls: -0.5),
      headlineSmall: _h(22, FontWeight.w600),
      titleLarge: _h(20, FontWeight.w500, ls: -0.2),
      titleMedium: _b(16, FontWeight.w600),
      titleSmall: _b(14, FontWeight.w600),
      bodyLarge: _b(16, FontWeight.w400),
      bodyMedium: _b(14, FontWeight.w400),
      bodySmall: _b(12, FontWeight.w400, color: AppColors.muted),
      labelLarge: _b(14, FontWeight.w600),
      labelMedium: _b(12, FontWeight.w600, color: AppColors.muted),
      labelSmall: _b(11, FontWeight.w600, color: AppColors.muted, ls: 0.5),
    );

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.line),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: _body,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.hairline)),
        titleTextStyle: _h(18, FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.hairline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.sidebar,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: _b(14, FontWeight.w400, color: AppColors.faint),
        labelStyle: _b(14, FontWeight.w400, color: AppColors.muted),
        floatingLabelStyle: _b(13, FontWeight.w600, color: AppColors.amber),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.amber, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: _b(14, FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: AppColors.line),
          textStyle: _b(14, FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.amber,
          textStyle: _b(14, FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.amber
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.canvas
                : AppColors.muted,
          ),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.line)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.elevated,
        selectedColor: AppColors.amber,
        showCheckmark: false,
        side: const BorderSide(color: AppColors.line),
        shape: const StadiumBorder(),
        labelStyle: _b(12, FontWeight.w600, color: AppColors.text),
        secondaryLabelStyle: _b(12, FontWeight.w700, color: AppColors.canvas),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.canvas,
        shape: CircleBorder(),
        elevation: 2,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.elevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.sidebar,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.hairline, space: 1),
            dataTableTheme: DataTableThemeData(
        headingRowColor: const WidgetStatePropertyAll(AppColors.sidebar),
        headingTextStyle: mono(
          size: 11,
          weight: FontWeight.w600,
          color: AppColors.muted,
        ),
        dataTextStyle: _b(13, FontWeight.w500),
        dividerThickness: 0.6,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.elevated,
        contentTextStyle: _b(14, FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.amber,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.amber,
        selectionColor: Color(0x4DE5A93C),
      ),
    );
  }
}
