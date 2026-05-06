import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Futuristic Black/White/Red Palette
  static const _primary = Color(0xFFFF003C);
  static const _background = Color(0xFF000000);
  static const _surface = Color(0xFF0A0A0A);
  static const _surfaceElevated = Color(0xFF121212);
  static const _border = Color(0xFF222222);
  static const _textPrimary = Color(0xFFFFFFFF);
  static const _textSecondary = Color(0xFF666666);
  static const _error = Color(0xFFFF003C);

  static ThemeData get dark => _buildTheme();

  static ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _primary,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _primary,
        surface: _surface,
        error: _error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _background,
        foregroundColor: _primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: _primary,
          letterSpacing: 3,
        ),
        iconTheme: const IconThemeData(color: _primary),
      ),
      cardTheme: CardThemeData(
        color: _surfaceElevated,
        elevation: 0,
        shadowColor: _primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _border, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _primary.withOpacity(0.15),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primary, size: 24);
          }
          return const IconThemeData(color: _textSecondary, size: 24);
        }),
      ),
      textTheme: GoogleFonts.orbitronTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: _textPrimary,
        displayColor: _textPrimary,
      ).copyWith(
        bodySmall: GoogleFonts.rubik(color: _textSecondary),
        bodyMedium: GoogleFonts.rubik(color: _textPrimary),
        bodyLarge: GoogleFonts.rubik(color: _textPrimary),
      ),
      iconTheme: const IconThemeData(color: _primary, size: 24),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: _primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: _borderOutline(),
        enabledBorder: _borderOutline(),
        focusedBorder: _borderOutline(focus: true),
        errorBorder: _borderOutline(error: true),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5)),
        labelStyle: const TextStyle(color: _textSecondary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceElevated,
        elevation: 16,
        shadowColor: _primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _border),
        ),
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _primary,
          letterSpacing: 2,
        ),
        contentTextStyle: GoogleFonts.rubik(
          fontSize: 14,
          color: _textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceElevated,
        contentTextStyle: const TextStyle(color: _textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surface,
        labelStyle: const TextStyle(color: _textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: _border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _border,
        thickness: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surfaceElevated,
        modalBackgroundColor: _surfaceElevated,
        elevation: 16,
        shadowColor: _primary,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primary,
        linearTrackColor: _border,
      ),
    );
  }

  static OutlineInputBorder _borderOutline({bool focus = false, bool error = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: error ? _error : (focus ? _primary : _border),
        width: focus ? 2 : 1,
      ),
    );
  }
}
