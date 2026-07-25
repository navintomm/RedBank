import 'package:flutter/material.dart';
import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'loading_indicator.dart';

class SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isError;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isError = false,
    this.icon,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Secondary buttons use a tonal surface
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isDisabled) {
      bgColor = isDark ? AppColors.surface1Dark : AppColors.surface1Light;
      textColor = isDark ? AppColors.disabledDark : AppColors.disabledLight;
      borderColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    } else if (widget.isError) {
      bgColor = isDark ? AppColors.errorDark.withOpacity(0.1) : AppColors.errorLight.withOpacity(0.1);
      textColor = isDark ? AppColors.errorDark : AppColors.errorLight;
      borderColor = isDark ? AppColors.errorDark.withOpacity(0.5) : AppColors.errorLight.withOpacity(0.5);
    } else {
      bgColor = isDark 
          ? (_isHovered ? AppColors.surface2Dark : AppColors.surface1Dark)
          : (_isHovered ? AppColors.surface2Light : AppColors.surface1Light);
      textColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
      borderColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    }

    // Interaction scales
    double scale = 1.0;
    if (_isPressed && !isDisabled) {
      scale = AppAnimations.buttonPressScale;
    } else if (_isHovered && !isDisabled) {
      scale = AppAnimations.hoverScale;
    }

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: widget.text,
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
              curve: AppAnimations.easeOutCubic,
              constraints: const BoxConstraints(minHeight: AppConstants.minTouchTarget),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Center(
                child: _buildContent(textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        width: AppConstants.iconSizeMd,
        height: AppConstants.iconSizeMd,
        child: LoadingIndicator(color: textColor, size: AppConstants.iconSizeSm),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: textColor, size: AppConstants.iconSizeMd),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          widget.text,
          style: AppTypography.getTextTheme(isDark: Theme.of(context).brightness == Brightness.dark).labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
