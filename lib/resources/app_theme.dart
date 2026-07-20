import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryDark = Color(0xFF0B1F4D);
  static const Color accent = Color(0xFFF97316);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color text = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color primarySoft = Color(0xFFEFF6FF);
  static const Color accentSoft = Color(0xFFFFEDD5);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color outline = Color(0xFFE5E7EB);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: accent,
      surface: surface,
      error: error,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Mulish',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(color: text, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: text, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: text, fontSize: 12),
        bodyMedium: TextStyle(color: text),
        bodySmall: TextStyle(color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: outline,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: primary),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(color: textSecondary),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primary, width: 1.2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: outline, width: 1),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.white;
        }),
        side: const BorderSide(color: outline, width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primarySoft;
          return outline;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFFD1D5DB),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: primaryDark,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
