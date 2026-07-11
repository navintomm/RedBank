import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CurrentLocationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDark;

  const CurrentLocationButton({
    super.key,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Move camera to current location',
      button: true,
      child: FloatingActionButton(
        heroTag: 'currentLocationBtn',
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: AppColors.primary,
        onPressed: onPressed,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
