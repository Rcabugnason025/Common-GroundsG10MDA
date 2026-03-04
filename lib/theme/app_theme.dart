import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.navbar,
      iconTheme: IconThemeData(color: AppColors.icon),
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(color: AppColors.icon),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: AppColors.textDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navbar.withAlpha((0.1 * 255).round()),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navbar,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
