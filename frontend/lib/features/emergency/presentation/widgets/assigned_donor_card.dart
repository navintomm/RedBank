import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/emergency_models.dart';

class AssignedDonorCard extends StatelessWidget {
  final EmergencyAssignmentModel assignment;
  
  // In a real implementation, you'd fetch the Donor profile using the assignment.donorId
  // For the UI, we'll accept these as optional overrides or use placeholders
  final String donorName;
  final bool isVerified;
  final String bloodGroup;
  final double reliabilityScore;

  const AssignedDonorCard({
    super.key,
    required this.assignment,
    this.donorName = 'Assigned Donor',
    this.isVerified = true,
    this.bloodGroup = 'Match',
    this.reliabilityScore = 4.8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'Assigned Donor Profile for $donorName',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              donorName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: AppSpacing.xxs),
                            const Icon(Icons.verified, color: AppColors.info, size: 18),
                          ]
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.warning, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            reliabilityScore.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Icon(Icons.water_drop, color: AppColors.primary, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            bloodGroup,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (assignment.estimatedArrival != null) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.secondary, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'ETA: ${_formatTime(assignment.estimatedArrival!)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
