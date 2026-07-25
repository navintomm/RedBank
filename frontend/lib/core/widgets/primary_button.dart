import 'package:flutter/material.dart';
import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'loading_indicator.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isError;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isError = false,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine colors
    Color bgColor;
    if (isDisabled && !widget.isLoading) {
      bgColor = isDark ? AppColors.disabledDark : AppColors.disabledLight;
    } else if (widget.isError) {
      bgColor = isDark ? AppColors.errorDark : AppColors.errorLight;
    } else {
      bgColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
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
                // Add a subtle gradient if primary enabled
                gradient: (!isDisabled && !widget.isError) ? AppColors.primaryGradient : null,
              ),
              child: Center(
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: AppAnimations.normal,
      child: widget.isLoading
          ? const SizedBox(
              key: ValueKey('loading'),
              width: AppConstants.iconSizeMd,
              height: AppConstants.iconSizeMd,
              child: LoadingIndicator(color: Colors.white, size: AppConstants.iconSizeSm),
            )
          : Row(
              key: const ValueKey('content'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: AppConstants.iconSizeMd),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  widget.text,
                  style: AppTypography.getTextTheme(isDark: false).labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
    );
  }
}
