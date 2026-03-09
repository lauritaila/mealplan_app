import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5F7D5E),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F9F7),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF7F9F7),
        elevation: 0,
      ),
      // textTheme: GoogleFonts.sourceSans3TextTheme(),
      // textTheme: GoogleFonts.libreBaskervilleTextTheme(),
    );
  }
}
