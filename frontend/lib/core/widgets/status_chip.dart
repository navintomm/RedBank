import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum StatusType { success, warning, error, info, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color color;
    switch (type) {
      case StatusType.success:
        color = isDark ? AppColors.successDark : AppColors.successLight;
        break;
      case StatusType.warning:
        color = isDark ? AppColors.warningDark : AppColors.warningLight;
        break;
      case StatusType.error:
        color = isDark ? AppColors.errorDark : AppColors.errorLight;
        break;
      case StatusType.info:
        color = isDark ? AppColors.infoDark : AppColors.infoLight;
        break;
      case StatusType.neutral:
        color = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: AppSpacing.borderRadiusPill,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.getTextTheme(isDark: isDark).labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
