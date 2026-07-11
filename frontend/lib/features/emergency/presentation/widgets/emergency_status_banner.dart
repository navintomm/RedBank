import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/emergency_models.dart';

class EmergencyStatusBanner extends StatelessWidget {
  final EmergencyRequestModel request;

  const EmergencyStatusBanner({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final config = _getBannerConfig(request.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? config.color.withOpacity(0.2) : config.color.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: config.color, width: 2),
        ),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.color, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  config.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: config.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (config.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    config.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _BannerConfig _getBannerConfig(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
      case 'CREATED':
        return _BannerConfig(
          title: 'Request Created',
          subtitle: 'Preparing to match with donors.',
          color: AppColors.info,
          icon: Icons.hourglass_empty,
        );
      case 'SEARCHING':
        return _BannerConfig(
          title: 'Searching for Donors',
          subtitle: 'Finding nearby eligible donors...',
          color: AppColors.info,
          icon: Icons.radar,
        );
      case 'DONORS_IDENTIFIED':
      case 'NOTIFICATIONS_SENT':
      case 'AWAITING_RESPONSES':
        return _BannerConfig(
          title: 'Awaiting Donor Response',
          subtitle: 'Notifications have been sent out.',
          color: AppColors.warning,
          icon: Icons.notifications_active,
        );
      case 'ACCEPTED':
        return _BannerConfig(
          title: 'Donor Found',
          subtitle: 'A donor has accepted this request.',
          color: AppColors.warning,
          icon: Icons.check_circle_outline,
        );
      case 'DONOR_TRAVELLING':
        return _BannerConfig(
          title: 'Donor is Travelling',
          subtitle: 'Donor is on their way to the hospital.',
          color: AppColors.warning,
          icon: Icons.directions_car,
        );
      case 'ARRIVED':
      case 'DONATION_IN_PROGRESS':
        return _BannerConfig(
          title: 'Donation in Progress',
          subtitle: 'Donor is currently at the hospital.',
          color: AppColors.success,
          icon: Icons.vaccines,
        );
      case 'COMPLETED':
        return _BannerConfig(
          title: 'Completed',
          subtitle: 'This emergency request has been successfully completed.',
          color: AppColors.success,
          icon: Icons.verified,
        );
      case 'CANCELLED':
        return _BannerConfig(
          title: 'Cancelled',
          subtitle: 'This request was cancelled.',
          color: AppColors.error,
          icon: Icons.cancel,
        );
      case 'FAILED':
      case 'EXPIRED':
      case 'NO_SHOW':
        return _BannerConfig(
          title: 'Failed to Complete',
          subtitle: 'This request could not be fulfilled.',
          color: AppColors.error,
          icon: Icons.error_outline,
        );
      default:
        return _BannerConfig(
          title: 'Unknown Status',
          subtitle: status,
          color: AppColors.textSecondaryLight,
          icon: Icons.help_outline,
        );
    }
  }
}

class _BannerConfig {
  final String title;
  final String? subtitle;
  final Color color;
  final IconData icon;

  _BannerConfig({
    required this.title,
    this.subtitle,
    required this.color,
    required this.icon,
  });
}
