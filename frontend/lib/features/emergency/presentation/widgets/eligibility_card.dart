import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class EligibilityCard extends StatelessWidget {
  final bool isEligible;
  final bool isAvailable;
  final bool isVerified;
  final bool passedCooldown;
  final String? rejectionReason;

  const EligibilityCard({
    super.key,
    required this.isEligible,
    this.isAvailable = true,
    this.isVerified = true,
    this.passedCooldown = true,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isEligible ? AppColors.success : AppColors.error;
    final backgroundColor = isDark 
        ? borderColor.withOpacity(0.1) 
        : borderColor.withOpacity(0.05);

    return Semantics(
      label: 'Eligibility Status: ${isEligible ? 'Eligible' : 'Not Eligible'}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEligible ? Icons.check_circle : Icons.cancel,
                  color: borderColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isEligible ? 'You are eligible to donate' : 'Currently ineligible',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: borderColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildChecklistItem('Availability active', isAvailable, theme, isDark),
            _buildChecklistItem('Identity verified', isVerified, theme, isDark),
            _buildChecklistItem('Donation cooldown passed', passedCooldown, theme, isDark),
            if (!isEligible && rejectionReason != null) ...[
              const SizedBox(height: AppSpacing.sm),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                rejectionReason!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String title, bool isChecked, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check : Icons.close,
            size: 16,
            color: isChecked ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              decoration: isChecked ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}
