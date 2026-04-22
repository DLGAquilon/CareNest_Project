import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const primary      = Color(0xFF1A6BB5);
  static const primaryLight = Color(0xFFE8F1FB);
  static const primaryDark  = Color(0xFF0D4A8A);
  static const accent       = Color(0xFF4CAF8A);
  static const danger       = Color(0xFFE53935);
  static const warning      = Color(0xFFF59E0B);
  static const success      = Color(0xFF2E7D52);

  // Backgrounds — shades of white
  static const bgPage       = Color(0xFFF7F8FC);
  static const bgCard       = Color(0xFFFFFFFF);
  static const bgInput      = Color(0xFFF4F6FA);
  static const bgChip       = Color(0xFFEEF2F9);

  // Text
  static const textPrimary   = Color(0xFF1A1D23);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint      = Color(0xFFB0B7C3);

  // Border
  static const border        = Color(0xFFE2E8F0);
  static const borderFocus   = Color(0xFF1A6BB5);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: bgPage,
    colorScheme: const ColorScheme.light(
      primary:   primary,
      secondary: accent,
      surface:   bgCard,
      error:     danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgCard,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Color(0x14000000),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: const CardThemeData(
      color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderFocus, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger),
      ),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      hintStyle:  const TextStyle(color: textHint, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: CircleBorder(),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: bgChip,
      labelStyle: const TextStyle(fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}