import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primarySage = Color(0xFF7D9E87);
  static const Color backgroundLight = Color(0xFFF8F9F8);
  static const Color backgroundDark = Color(0xFF1A1E1B);

  static const Map<int, Color> sagePalette = {
    50: Color(0xFFF4F7F5),
    100: Color(0xFFE9EFEB),
    200: Color(0xFFD3DFD7),
    300: Color(0xFFBDCFC3),
    400: Color(0xFFA7BFAF),
    500: Color(0xFF7D9E87),
    600: Color(0xFF6A8773),
    700: Color(0xFF576F5F),
    800: Color(0xFF44574B),
    900: Color(0xFF313F37),
  };

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySage,
        primary: primarySage,
        onPrimary: Colors.white,
        surface: backgroundLight,
        onSurface: sagePalette[900]!,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: GoogleFonts.publicSansTextTheme(),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySage,
        primary: primarySage,
        onPrimary: Colors.white,
        surface: backgroundDark,
        onSurface: sagePalette[50]!,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: GoogleFonts.publicSansTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF252A26),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
