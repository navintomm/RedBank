import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class EmergencyTimelineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final bool isError;

  const EmergencyTimelineTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLast = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color lineColor = isCompleted || isCurrent
        ? (isError ? AppColors.error : AppColors.primary)
        : (isDark ? AppColors.dividerDark : AppColors.dividerLight);

    final Color iconColor = isCompleted
        ? (isError ? AppColors.error : AppColors.success)
        : (isCurrent
            ? AppColors.primary
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline graphics
          SizedBox(
            width: 30,
            child: Column(
              children: [
                // Top line (transparent if first, else solid if completed)
                Container(
                  width: 2,
                  height: 10,
                  color: isCompleted || isCurrent ? lineColor : Colors.transparent,
                ),
                // Indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent && !isError
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: iconColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            isError ? Icons.close : Icons.check,
                            size: 14,
                            color: iconColor,
                          )
                        : (isCurrent
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: iconColor,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null),
                  ),
                ),
                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? lineColor
                          : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10), // Align with indicator
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent || isCompleted
                          ? (isError
                              ? AppColors.error
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight))
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
