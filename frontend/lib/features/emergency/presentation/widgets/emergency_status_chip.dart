import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class EmergencyStatusChip extends StatelessWidget {
  final String status;

  const EmergencyStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: AppSpacing.borderRadiusCircular,
        border: Border.all(color: _getBorderColor(context)),
      ),
      child: Text(
        _formatStatus(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
        semanticsLabel: 'Status: ${_formatStatus(status)}',
      ),
    );
  }

  String _formatStatus(String rawStatus) {
    return rawStatus.replaceAll('_', ' ').toUpperCase();
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status.toUpperCase()) {
      case 'DRAFT':
      case 'CREATED':
      case 'SEARCHING':
      case 'DONORS_IDENTIFIED':
        return isDark ? AppColors.info.withOpacity(0.2) : AppColors.info.withOpacity(0.1);
      case 'NOTIFICATIONS_SENT':
      case 'AWAITING_RESPONSES':
      case 'ACCEPTED':
      case 'DONOR_TRAVELLING':
      case 'ARRIVED':
      case 'DONATION_IN_PROGRESS':
        return isDark ? AppColors.warning.withOpacity(0.2) : AppColors.warning.withOpacity(0.1);
      case 'COMPLETED':
        return isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1);
      case 'CANCELLED':
      case 'FAILED':
      case 'EXPIRED':
      case 'NO_SHOW':
        return isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1);
      default:
        return isDark ? AppColors.dividerDark : AppColors.dividerLight;
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
      case 'CREATED':
      case 'SEARCHING':
      case 'DONORS_IDENTIFIED':
        return AppColors.info;
      case 'NOTIFICATIONS_SENT':
      case 'AWAITING_RESPONSES':
      case 'ACCEPTED':
      case 'DONOR_TRAVELLING':
      case 'ARRIVED':
      case 'DONATION_IN_PROGRESS':
        return AppColors.warning;
      case 'COMPLETED':
        return AppColors.success;
      case 'CANCELLED':
      case 'FAILED':
      case 'EXPIRED':
      case 'NO_SHOW':
        return AppColors.error;
      default:
        return Theme.of(context).brightness == Brightness.dark 
            ? AppColors.dividerDark 
            : AppColors.dividerLight;
    }
  }

  Color _getTextColor(BuildContext context) {
    return _getBorderColor(context);
  }
}
