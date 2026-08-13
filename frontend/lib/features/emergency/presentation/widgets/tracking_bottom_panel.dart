import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'emergency_timeline.dart';
import '../../providers/tracking_provider.dart'; // To get TrackingState

class TrackingBottomPanel extends StatelessWidget {
  final TrackingState state;
  final double distanceRemaining;
  final String eta;
  final String statusMessage;
  final Color statusColor;
  final bool isStale;
  final Widget? primaryButton;
  final List<Widget> actionButtons;
  final ScrollController? scrollController;

  const TrackingBottomPanel({
    super.key,
    required this.state,
    required this.distanceRemaining,
    required this.eta,
    required this.statusMessage,
    required this.statusColor,
    required this.isStale,
    this.primaryButton,
    required this.actionButtons,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grabber handle for aesthetics
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    label: 'Distance remaining: ${distanceRemaining > 1000 ? '${(distanceRemaining / 1000).toStringAsFixed(1)} kilometers' : '${distanceRemaining.toStringAsFixed(0)} meters'}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distance',
                          style: AppTypography.getTextTheme(isDark: isDark).labelMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          distanceRemaining > 1000 
                              ? '${(distanceRemaining / 1000).toStringAsFixed(1)} km'
                              : '${distanceRemaining.toStringAsFixed(0)} m',
                          style: AppTypography.getTextTheme(isDark: isDark).headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    label: 'Estimated time of arrival: $eta',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ETA',
                          style: AppTypography.getTextTheme(isDark: isDark).labelMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          eta,
                          style: AppTypography.getTextTheme(isDark: isDark).headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              EmergencyTimeline(currentStatus: state.status),
              
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              
              Semantics(
                label: 'Current status: $statusMessage',
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        statusMessage,
                        style: AppTypography.getTextTheme(isDark: isDark).bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (state.currentDonorLocation != null && state.status == 'DONOR_TRAVELLING')
                      Text(
                        'Updated ${DateTime.now().difference(state.currentDonorLocation!.timestamp.toLocal()).inSeconds}s ago',
                        style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
                          color: isStale ? AppColors.warning : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              if (primaryButton != null) ...[
                primaryButton!,
                const SizedBox(height: AppSpacing.md),
              ],

              if (actionButtons.isNotEmpty)
                Row(
                  children: [
                    for (int i = 0; i < actionButtons.length; i++) ...[
                      actionButtons[i],
                      if (i < actionButtons.length - 1)
                        const SizedBox(width: AppSpacing.md),
                    ]
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
