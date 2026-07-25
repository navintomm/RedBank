import 'package:flutter/material.dart';

class AppShadows {
  // Using very soft, dispersed shadows instead of harsh Material elevation
  
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      offset: Offset(0, 4),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];
}
