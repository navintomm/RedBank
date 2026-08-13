import 'package:flutter/animation.dart';

class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  // Curves
  static const Curve easeOutCubic = Cubic(0.215, 0.61, 0.355, 1);
  static const Curve easeInOut = Curves.easeInOut;
  
  // Spring Simulation for Micro-interactions (e.g. Button Press Scale)
  static const SpringDescription defaultSpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );
  
  // Reusable Interaction Definitions
  static const double buttonPressScale = 0.96;
  static const double cardPressScale = 0.98;
  static const double hoverScale = 1.02;
  static const double disabledOpacity = 0.5;
}
