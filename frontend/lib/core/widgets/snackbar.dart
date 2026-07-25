import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';

enum SnackBarType { success, error, info }

void showMedicalSnackBar({
  required BuildContext context,
  required String message,
  SnackBarType type = SnackBarType.info,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  Color bgColor;
  IconData icon;
  switch (type) {
    case SnackBarType.success:
      bgColor = isDark ? AppColors.successDark : AppColors.successLight;
      icon = Icons.check_circle_outline;
      break;
    case SnackBarType.error:
      bgColor = isDark ? AppColors.errorDark : AppColors.errorLight;
      icon = Icons.error_outline;
      break;
    case SnackBarType.info:
      bgColor = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
      icon = Icons.info_outline;
      break;
  }

  final textColor = (type == SnackBarType.info)
      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
      : Colors.white;
      
  final iconColor = (type == SnackBarType.info)
      ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
      : Colors.white;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppSpacing.borderRadiusMd,
          boxShadow: AppShadows.floating,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTypography.getTextTheme(isDark: isDark).bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
