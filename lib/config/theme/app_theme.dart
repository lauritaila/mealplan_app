import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color.fromARGB(255, 39, 105, 38),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Color.fromARGB(255, 224, 234, 224),
      appBarTheme: AppBarTheme(
        backgroundColor: Color.fromARGB(255, 224, 234, 224),
        elevation: 0,
      ),
      // textTheme: GoogleFonts.sourceSans3TextTheme(),
      // textTheme: GoogleFonts.libreBaskervilleTextTheme(),
    );
  }
}
