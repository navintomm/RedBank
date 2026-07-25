import 'package:flutter/material.dart';

class AppColors {
  // Brand Semantic Colors
  static const Color primaryLight = Color(0xFFE03E3E);
  static const Color primaryDark = Color(0xFFFF5C5C);
  
  static const Color secondaryLight = Color(0xFF007AFF);
  static const Color secondaryDark = Color(0xFF0A84FF);

  // Status Colors
  static const Color successLight = Color(0xFF34C759);
  static const Color successDark = Color(0xFF30D158);
  
  static const Color warningLight = Color(0xFFFF9500);
  static const Color warningDark = Color(0xFFFF9F0A);
  
  static const Color errorLight = Color(0xFFFF3B30);
  static const Color errorDark = Color(0xFFFF453A);
  
  static const Color infoLight = Color(0xFF32ADE6);
  static const Color infoDark = Color(0xFF64D2FF);

  // Generic Aliases (defaults to light for static references)
  static const Color primary = primaryLight;
  static const Color secondary = secondaryLight;
  static const Color success = successLight;
  static const Color warning = warningLight;
  static const Color error = errorLight;
  static const Color info = infoLight;

  // Surface Hierarchy - Light
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color surface1Light = Color(0xFFFFFFFF);
  static const Color surface2Light = Color(0xFFF9F9F9);
  static const Color elevatedLight = Color(0xFFFFFFFF);
  static const Color glassLight = Color(0xBFFFFFFF); // 75% white

  // Surface Hierarchy - Dark
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surface1Dark = Color(0xFF1C1C1E);
  static const Color surface2Dark = Color(0xFF2C2C2E);
  static const Color elevatedDark = Color(0xFF3A3A3C);
  static const Color glassDark = Color(0xBF282828); // 75% dark gray

  // Surface Aliases
  static const Color surfaceLight = surface1Light;
  static const Color surfaceDark = surface1Dark;

  // Text Colors - Light
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF3C3C43); // Opacity handled via text theme
  static const Color textTertiaryLight = Color(0x4D3C3C43); // 30% opacity

  // Text Colors - Dark
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFEBEBF5); // Opacity handled via text theme
  static const Color textTertiaryDark = Color(0x4DEBEBF5); // 30% opacity

  // Utilities
  static const Color dividerLight = Color(0x2E3C3C43); // 18% opacity
  static const Color dividerDark = Color(0xA6545458); // 65% opacity
  
  static const Color disabledLight = Color(0xFFD1D1D6);
  static const Color disabledDark = Color(0xFF3A3A3C);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE03E3E), Color(0xFFC72828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF2F2F7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
