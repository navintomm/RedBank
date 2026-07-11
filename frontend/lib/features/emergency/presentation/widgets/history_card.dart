import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/emergency_models.dart';

class HistoryCard extends StatelessWidget {
  final EmergencyRequestModel request;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final statusColor = _getStatusColor(request.status);
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final amPm = request.createdAt.hour >= 12 ? 'PM' : 'AM';
    final hour12 = request.createdAt.hour == 0 ? 12 : (request.createdAt.hour > 12 ? request.createdAt.hour - 12 : request.createdAt.hour);
    final minuteStr = request.createdAt.minute.toString().padLeft(2, '0');
    final formattedDate = '${monthNames[request.createdAt.month - 1]} ${request.createdAt.day.toString().padLeft(2, '0')}, ${request.createdAt.year}';
    final formattedTime = '${hour12.toString().padLeft(2, '0')}:$minuteStr $amPm';

    return Semantics(
      label: 'Emergency request for ${request.hospitalName}, Status: ${request.status}',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      request.status.replaceAll('_', ' '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '$formattedDate, $formattedTime',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                request.hospitalName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.water_drop, color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    request.bloodGroup.replaceAll('_POSITIVE', '+').replaceAll('_NEGATIVE', '-'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.local_hospital, color: AppColors.secondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    request.emergencyType.replaceAll('_', ' '),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.monitor_weight, color: AppColors.info, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${request.unitsRequired} Units',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return AppColors.success;
      case 'CANCELLED':
      case 'EXPIRED':
      case 'FAILED':
      case 'NO_SHOW':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}
