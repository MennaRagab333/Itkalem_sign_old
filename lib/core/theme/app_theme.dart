import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF050A10);
  static const Color cardBg = Color(0xFF132235);
  static const Color primaryBlue = Color(0xFF3D79F8);
  static const Color textGrey = Color(0xFF8E94A3);

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color cardBgLight = Color(0xFFEBF4FF);
  static const Color borderLight = Color(0xFFBFDBFE);
  static const Color textDark = Color(0xFF1E3A8A);
  static const Color primaryIndigo = Color(0xFF1E3A8A);
  static const Color textGreyLight = Color(0xFF475569);
}

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primaryBlue,
  cardColor: AppColors.cardBg,
  fontFamily: 'Arial',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: AppColors.textGrey),
  ),
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  primaryColor: AppColors.primaryIndigo,
  cardColor: AppColors.cardBgLight,
  dividerColor: AppColors.borderLight,
  fontFamily: 'Arial',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.primaryIndigo),
    titleTextStyle: TextStyle(
      color: AppColors.primaryIndigo,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: AppColors.textGreyLight),
  ),
  iconTheme: const IconThemeData(color: AppColors.primaryIndigo),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryIndigo,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryIndigo,
    primary: AppColors.primaryIndigo,
    surface: AppColors.cardBgLight,
    onSurface: AppColors.primaryIndigo,
  ),
);