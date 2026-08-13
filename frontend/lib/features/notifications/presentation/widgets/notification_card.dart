import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/surface_card.dart';

class NotificationCard extends StatelessWidget {
  final RemoteMessage message;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.message,
    this.isRead = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = message.notification?.title ?? 'New Notification';
    final body = message.notification?.body ?? '';
    final timestamp = message.sentTime ?? DateTime.now();

    return SurfaceCard(
      elevated: false,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: isRead ? null : Border(
            left: BorderSide(
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isRead 
                  ? (isDark ? AppColors.surface2Dark : AppColors.surface2Light)
                  : (isDark ? AppColors.primaryDark : AppColors.primaryLight).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForData(message.data),
                color: isRead 
                  ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                  : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.getTextTheme(isDark: isDark).titleMedium?.copyWith(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatTimeago(timestamp),
                        style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    style: AppTypography.getTextTheme(isDark: isDark).bodyMedium?.copyWith(
                      color: isRead 
                        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'EMERGENCY_REQUEST':
        return Icons.emergency;
      case 'DONOR_ACCEPTED':
        return Icons.check_circle_outline;
      case 'TRACKING_UPDATE':
        return Icons.location_on_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  String _formatTimeago(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
