import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color? consistencyRingActive;
  final Color? consistencyRingBackground;
  final Color? chartTabBackground;
  final Color? chartTabSelectedText;
  final Color? achievementIconBackground;
  final Color? achievementIcon;
  final Color? darkSage;
  final Color? slateGrey;
  final Color? textDarkBlue;
  
  // Macro Colors
  final Color? macroProtein;
  final Color? macroFat;
  final Color? macroCarbs;
  final Color? macroCalories;

  const AppCustomColors({
    this.consistencyRingActive,
    this.consistencyRingBackground,
    this.chartTabBackground,
    this.chartTabSelectedText,
    this.achievementIconBackground,
    this.achievementIcon,
    this.darkSage,
    this.slateGrey,
    this.textDarkBlue,
    this.macroProtein,
    this.macroFat,
    this.macroCarbs,
    this.macroCalories,
  });

  @override
  AppCustomColors copyWith({
    Color? consistencyRingActive,
    Color? consistencyRingBackground,
    Color? chartTabBackground,
    Color? chartTabSelectedText,
    Color? achievementIconBackground,
    Color? achievementIcon,
    Color? darkSage,
    Color? slateGrey,
    Color? textDarkBlue,
    Color? macroProtein,
    Color? macroFat,
    Color? macroCarbs,
    Color? macroCalories,
  }) {
    return AppCustomColors(
      consistencyRingActive: consistencyRingActive ?? this.consistencyRingActive,
      consistencyRingBackground:
          consistencyRingBackground ?? this.consistencyRingBackground,
      chartTabBackground: chartTabBackground ?? this.chartTabBackground,
      chartTabSelectedText: chartTabSelectedText ?? this.chartTabSelectedText,
      achievementIconBackground:
          achievementIconBackground ?? this.achievementIconBackground,
      achievementIcon: achievementIcon ?? this.achievementIcon,
      darkSage: darkSage ?? this.darkSage,
      slateGrey: slateGrey ?? this.slateGrey,
      textDarkBlue: textDarkBlue ?? this.textDarkBlue,
      macroProtein: macroProtein ?? this.macroProtein,
      macroFat: macroFat ?? this.macroFat,
      macroCarbs: macroCarbs ?? this.macroCarbs,
      macroCalories: macroCalories ?? this.macroCalories,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) {
      return this;
    }
    return AppCustomColors(
      consistencyRingActive:
          Color.lerp(consistencyRingActive, other.consistencyRingActive, t),
      consistencyRingBackground:
          Color.lerp(consistencyRingBackground, other.consistencyRingBackground, t),
      chartTabBackground: Color.lerp(chartTabBackground, other.chartTabBackground, t),
      chartTabSelectedText:
          Color.lerp(chartTabSelectedText, other.chartTabSelectedText, t),
      achievementIconBackground:
          Color.lerp(achievementIconBackground, other.achievementIconBackground, t),
      achievementIcon: Color.lerp(achievementIcon, other.achievementIcon, t),
      darkSage: Color.lerp(darkSage, other.darkSage, t),
      slateGrey: Color.lerp(slateGrey, other.slateGrey, t),
      textDarkBlue: Color.lerp(textDarkBlue, other.textDarkBlue, t),
      macroProtein: Color.lerp(macroProtein, other.macroProtein, t),
      macroFat: Color.lerp(macroFat, other.macroFat, t),
      macroCarbs: Color.lerp(macroCarbs, other.macroCarbs, t),
      macroCalories: Color.lerp(macroCalories, other.macroCalories, t),
    );
  }
}

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

  static final AppCustomColors _lightCustomColors = AppCustomColors(
    consistencyRingActive: const Color(0xFF7BA082),
    consistencyRingBackground: const Color(0xFFE8F0E8),
    chartTabBackground: const Color(0xFFE9EFEB),
    chartTabSelectedText: const Color(0xFF4C6B4F),
    achievementIconBackground: const Color(0xFFDCE6DE),
    achievementIcon: const Color(0xFF7BA082),
    darkSage: const Color(0xFF5C7861),
    slateGrey: const Color(0xFF64748B),
    textDarkBlue: const Color(0xFF001B3A),
    macroProtein: const Color(0xFF4C6B4F),
    macroFat: const Color(0xFF4A90E2),
    macroCarbs: const Color(0xFFD4833B),
    macroCalories: const Color(0xFFE67E22),
  );

  static final AppCustomColors _darkCustomColors = AppCustomColors(
    consistencyRingActive: const Color(0xFF7BA082),
    consistencyRingBackground: const Color(0xFF2D352F),
    chartTabBackground: const Color(0xFF313F37),
    chartTabSelectedText: const Color(0xFFA7BFAF),
    achievementIconBackground: const Color(0xFF313F37),
    achievementIcon: const Color(0xFF7BA082),
    darkSage: const Color(0xFFA7BFAF),
    slateGrey: const Color(0xFF94A3B8),
    textDarkBlue: const Color(0xFFE9EFEB),
    macroProtein: const Color(0xFF7BA082),
    macroFat: const Color(0xFF5DA9E9),
    macroCarbs: const Color(0xFFE6A26A),
    macroCalories: const Color(0xFFF39C12),
  );

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySage,
        primary: primarySage,
        onPrimary: Colors.white,
        surface: backgroundLight,
        onSurface: sagePalette[900]!,
        surfaceContainerLow: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF001B3A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: primarySage,
        unselectedItemColor: Colors.grey,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primarySage.withValues(alpha: 0.6), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primarySage.withValues(alpha: 0.6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primarySage, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade900, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade900, width: 2),
        ),
        isDense: true,
      ),
      textTheme: GoogleFonts.publicSansTextTheme(),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: [_lightCustomColors],
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
        surfaceContainerLow: const Color(0xFF252A26),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFE9EFEB),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundDark,
        elevation: 0,
        selectedItemColor: primarySage,
        unselectedItemColor: Colors.grey,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252A26),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primarySage.withValues(alpha: 0.6), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primarySage.withValues(alpha: 0.6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primarySage, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade900, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade900, width: 2),
        ),
        isDense: true,
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
      extensions: [_darkCustomColors],
    );
  }
}
