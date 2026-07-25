import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Roboto';

  static TextTheme getTextTheme({required bool isDark}) {
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? const Color(0x99EBEBF5) : const Color(0x993C3C43); // ~60% opacity

    return TextTheme(
      displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 40, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 36, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5),
      displaySmall: TextStyle(fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5),
      
      headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w600, color: textColor, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w600, color: textColor, letterSpacing: -0.5),
      headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600, color: textColor, letterSpacing: -0.5),
      
      titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
      titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
      
      bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
      bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, color: secondaryTextColor),
      
      labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
      labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
      labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w500, color: secondaryTextColor),
    );
  }
}
