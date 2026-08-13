import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/emergency_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/icon_button.dart';

class TrackingSummaryCard extends StatelessWidget {
  final EmergencyRequestModel emergency;
  final String title;
  final VoidCallback? onRefresh;

  const TrackingSummaryCard({
    super.key,
    required this.emergency,
    required this.title,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'Emergency tracking for ${emergency.hospitalName}',
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Row(
          children: [
            MedicalIconButton(
              icon: Icons.arrow_back,
              isGlass: false,
              hasBackground: false,
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.getTextTheme(isDark: isDark).titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    emergency.hospitalName,
                    style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(width: AppSpacing.sm),
              MedicalIconButton(
                icon: Icons.my_location,
                isGlass: false,
                hasBackground: true,
                onPressed: onRefresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
