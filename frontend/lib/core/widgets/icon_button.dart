import 'package:flutter/material.dart';
import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class MedicalIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isGlass;
  final bool hasBackground;
  final double size;

  const MedicalIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isGlass = false,
    this.hasBackground = true,
    this.size = AppConstants.minTouchTarget,
  });

  @override
  State<MedicalIconButton> createState() => _MedicalIconButtonState();
}

class _MedicalIconButtonState extends State<MedicalIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = Colors.transparent;
    if (widget.hasBackground) {
      if (widget.isGlass) {
        bgColor = isDark ? AppColors.glassDark : AppColors.glassLight;
      } else {
        bgColor = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
      }
      
      if (_isHovered && !isDisabled) {
        // slightly darken/lighten on hover
        bgColor = isDark ? Colors.white12 : Colors.black12;
      }
    }

    final iconColor = isDisabled 
        ? (isDark ? AppColors.disabledDark : AppColors.disabledLight)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    double scale = 1.0;
    if (_isPressed && !isDisabled) {
      scale = AppAnimations.buttonPressScale;
    } else if (_isHovered && !isDisabled) {
      scale = AppAnimations.hoverScale;
    }

    return Semantics(
      button: true,
      enabled: !isDisabled,
      child: MouseRegion(
        cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            if (!isDisabled) widget.onPressed?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: scale,
            duration: AppAnimations.fast,
            curve: AppAnimations.easeOutCubic,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: widget.isGlass ? Border.all(color: Colors.white24, width: 1) : null,
              ),
              child: Center(
                child: Icon(widget.icon, color: iconColor, size: widget.size * 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
