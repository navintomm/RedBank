import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_animations.dart';

class EmergencyTimeline extends StatelessWidget {
  final String currentStatus;

  const EmergencyTimeline({
    super.key,
    required this.currentStatus,
  });

  // Map of statuses in order of progression
  static const List<Map<String, dynamic>> _steps = [
    {'status': 'SEARCHING', 'label': 'Requested', 'icon': Icons.sensors},
    {'status': 'DONORS_IDENTIFIED', 'label': 'Matching', 'icon': Icons.people_alt_outlined},
    {'status': 'ACCEPTED', 'label': 'Donor Found', 'icon': Icons.check_circle_outline},
    {'status': 'DONOR_TRAVELLING', 'label': 'Travelling', 'icon': Icons.directions_car_outlined},
    {'status': 'ARRIVED', 'label': 'At Hospital', 'icon': Icons.local_hospital_outlined},
  ];

  int _getCurrentStepIndex(String status) {
    final upperStatus = status.toUpperCase();
    
    if (upperStatus == 'PENDING' || upperStatus == 'AWAITING_RESPONSES') {
      return 0; // Still requesting
    }
    if (upperStatus == 'NOTIFICATIONS_SENT') {
      return 1; // Matching
    }
    if (upperStatus == 'DONATION_IN_PROGRESS') {
      return 4; // Beyond arrived
    }
    if (upperStatus == 'COMPLETED') {
      return 5; // All steps done
    }

    // Exact matches
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i]['status'] == upperStatus) {
        return i;
      }
    }
    return 0; // Default
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTerminal = ['COMPLETED', 'CANCELLED', 'FAILED', 'EXPIRED', 'NO_SHOW'].contains(currentStatus.toUpperCase());
    
    int currentIndex = isTerminal && currentStatus.toUpperCase() != 'COMPLETED'
        ? -1 // Error state
        : _getCurrentStepIndex(currentStatus);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_steps.length, (index) {
            final step = _steps[index];
            final isCompleted = currentIndex > index || currentStatus.toUpperCase() == 'COMPLETED';
            final isActive = currentIndex == index && !isTerminal;

            return Expanded(
              child: _buildTimelineStep(
                context: context,
                label: step['label'] as String,
                icon: step['icon'] as IconData,
                isCompleted: isCompleted,
                isActive: isActive,
                isDark: isDark,
                isLast: index == _steps.length - 1,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTimelineStep({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
    required bool isDark,
    required bool isLast,
  }) {
    Color iconColor;
    Color circleColor;
    Color lineColor;

    if (isCompleted) {
      iconColor = Colors.white;
      circleColor = AppColors.success;
      lineColor = AppColors.success;
    } else if (isActive) {
      iconColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
      circleColor = (isDark ? AppColors.primaryDark : AppColors.primaryLight).withOpacity(0.15);
      lineColor = (isDark ? AppColors.dividerDark : AppColors.dividerLight);
    } else {
      iconColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      circleColor = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
      lineColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 2,
                color: isCompleted ? lineColor : Colors.transparent, // Only show trailing line if completed
              ),
            ),
            AnimatedContainer(
              duration: AppAnimations.normal,
              width: isActive ? 36 : 32,
              height: isActive ? 36 : 32,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                border: isActive ? Border.all(color: iconColor, width: 2) : null,
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                color: isLast ? Colors.transparent : lineColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.getTextTheme(isDark: isDark).labelSmall?.copyWith(
            color: isActive 
                ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
