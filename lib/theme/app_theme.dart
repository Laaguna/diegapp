import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);

  static const Color _lightBgStart = Color(0xFFF8FAFC);
  static const Color _lightBgEnd = Color(0xFFE2E8F0);
  static const Color _darkBgStart = Color(0xFF0B0B0F);
  static const Color _darkBgEnd = Color(0xFF1E1E2A);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      textTheme: _textTheme(scheme.onSurface),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      textTheme: _textTheme(scheme.onSurface),
    );
  }

  static TextTheme _textTheme(Color onSurface) {
    return TextTheme(
      bodyLarge: TextStyle(color: onSurface),
      bodyMedium: TextStyle(color: onSurface),
      bodySmall: TextStyle(color: onSurface),
      titleLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
    );
  }

  static LinearGradient backgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [_darkBgStart, _darkBgEnd]
          : [_lightBgStart, _lightBgEnd],
    );
  }

  static Color cumplimientoColor(double value) {
    if (value < 50) return dangerColor;
    if (value < 80) return warningColor;
    return successColor;
  }
}
