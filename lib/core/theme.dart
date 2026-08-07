import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1E293B);    // Slate Navy
  static const Color primaryHover = Color(0xFF0F172A);
  static const Color accent = Color(0xFF2563EB);     // Corporate Blue
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      surface: surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
  );
}