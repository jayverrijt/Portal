import 'package:flutter/material.dart';

class NordColors {
  // Polar Night
  static const nord0 = Color(0xFF2E3440);
  static const nord1 = Color(0xFF3B4252);
  static const nord2 = Color(0xFF434C5E);
  static const nord3 = Color(0xFF4C566A);

  // Snow Storm
  static const nord4 = Color(0xFFD8DEE9);
  static const nord5 = Color(0xFFE5E9F0);
  static const nord6 = Color(0xFFECEFF4);

  // Frost
  static const nord7 = Color(0xFF8FBCBB);
  static const nord8 = Color(0xFF88C0D0);
  static const nord9 = Color(0xFF81A1C1);
  static const nord10 = Color(0xFF5E81AC);

  // Aurora
  static const nord11 = Color(0xFFBF616A);
  static const nord12 = Color(0xFFD08770);
  static const nord13 = Color(0xFFEBCB8B);
  static const nord14 = Color(0xFFA3BE8C);
  static const nord15 = Color(0xFFB48EAD);
}

class NordTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NordColors.nord0,
      primaryColor: NordColors.nord8,
      colorScheme: const ColorScheme.dark(
        primary: NordColors.nord8,
        secondary: NordColors.nord9,
        surface: NordColors.nord1,
        error: NordColors.nord11,
      ),
      cardTheme: CardThemeData(
        color: NordColors.nord1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: NordColors.nord2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NordColors.nord0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: NordColors.nord6,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}