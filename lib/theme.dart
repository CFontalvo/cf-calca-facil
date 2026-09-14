import 'package:flutter/material.dart';

const cfNavy = Color(0xFF002D5B);
const cfCoral = Color(0xFFEC5B53);
const cfInk = Color(0xFF35373A);
const cfCanvas = Color(0xFFFEFAFA);
const cfSoftBlue = Color(0xFFE9F1F8);
const cfSoftCoral = Color(0xFFFFECEA);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: cfNavy,
    brightness: Brightness.light,
    primary: cfNavy,
    secondary: cfCoral,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: cfCanvas,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: cfNavy,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
      headlineSmall: TextStyle(color: cfNavy, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: cfNavy, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: cfInk, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(color: cfInk, height: 1.35),
      bodyMedium: TextStyle(color: cfInk, height: 1.35),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cfCanvas,
      foregroundColor: cfNavy,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: cfNavy,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cfNavy,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cfNavy,
        side: const BorderSide(color: cfNavy),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE7E2E2)),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: cfCoral,
      thumbColor: cfCoral,
      inactiveTrackColor: Color(0xFFFFCECA),
    ),
  );
}
