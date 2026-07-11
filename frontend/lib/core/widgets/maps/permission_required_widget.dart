import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../primary_button.dart';

class PermissionRequiredWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final bool isGpsDisabled;

  const PermissionRequiredWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.isGpsDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isGpsDisabled ? Icons.location_off : Icons.gpp_bad,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isGpsDisabled ? 'GPS Disabled' : 'Permission Required',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: 'RETRY',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
