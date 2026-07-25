import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/redbank_scaffold.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/icon_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/emergency_models.dart';
import '../../providers/emergency_provider.dart';

import '../widgets/emergency_status_banner.dart';
import '../widgets/eligibility_card.dart';
import '../widgets/travel_time_card.dart';
import '../widgets/response_action_panel.dart';

class DonorResponseScreen extends ConsumerStatefulWidget {
  final String requestId;

  const DonorResponseScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<DonorResponseScreen> createState() => _DonorResponseScreenState();
}

class _DonorResponseScreenState extends ConsumerState<DonorResponseScreen> {
  bool _isAccepting = false;
  bool _showAlreadyAcceptedScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emergencyNotifierProvider.notifier).getRequestDetails(widget.requestId);
    });
  }

  Future<void> _handleAccept() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface1Dark : AppColors.surface1Light,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
        title: const Text('Confirm Acceptance'),
        content: const Text(
          'Are you sure you want to accept this emergency request? '
          'You will be expected to travel to the hospital immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('CANCEL', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ),
          PrimaryButton(
            text: 'ACCEPT',
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    setState(() => _isAccepting = true);

    final success = await ref.read(emergencyNotifierProvider.notifier).acceptRequest(widget.requestId);

    if (!mounted) return;
    setState(() => _isAccepting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully accepted the emergency!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Let the user view the updated status banner showing "DONOR_TRAVELLING" or similar.
    } else {
      final error = ref.read(emergencyNotifierProvider).error;
      final errorStr = error?.toString() ?? '';

      if (errorStr.contains('InvalidTransitionException')) {
        // 409 Conflict: Another donor already took it
        setState(() => _showAlreadyAcceptedScreen = true);
      } else if (errorStr.contains('RequestExpiredException')) {
        _showErrorSnackBar('This request has expired and is no longer valid.');
      } else if (errorStr.contains('AuthorizationException')) {
        _showErrorSnackBar('Your session expired. Please log in again.');
      } else {
        _showErrorSnackBar('Network or system error. Please try again.');
      }
    }
  }

  void _handleDecline() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasonController = TextEditingController();
    final shouldDecline = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface1Dark : AppColors.surface1Light,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
        title: const Text('Decline Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Would you like to provide a reason? (Optional)'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'e.g. Too far away',
                border: OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMd),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide: BorderSide(color: isDark ? AppColors.primaryDark : AppColors.primaryLight),
                ),
              ),
              maxLines: 2,
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('CANCEL', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('DECLINE', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldDecline == true) {
      setState(() => _isAccepting = true);
      final success = await ref.read(emergencyNotifierProvider.notifier).declineRequest(widget.requestId);
      
      if (mounted) {
        setState(() => _isAccepting = false);
        if (success) {
          context.pop(); // Go back to dashboard
        } else {
          _showErrorSnackBar('Failed to decline. Please try again.');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showAlreadyAcceptedScreen) {
      return _buildAlreadyAcceptedScreen();
    }

    final stateAsync = ref.watch(emergencyNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RedBankScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Emergency Request'),
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: MedicalIconButton(
            icon: Icons.arrow_back,
            isGlass: true,
            hasBackground: true,
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorStateWidget(
            message: 'Failed to load request data.',
            onRetry: () => ref.read(emergencyNotifierProvider.notifier).getRequestDetails(widget.requestId),
          ),
          data: (state) {
            final request = state.currentRequest;
            if (request == null) {
              return const Center(child: Text('Request not found.'));
            }

            // Mocking donor eligibility. In a real app this would come from a donor provider
            const isEligible = true;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EmergencyStatusBanner(request: request),
                  const SizedBox(height: AppSpacing.lg),

                  const SectionHeader(title: 'Emergency Summary'),
                  _buildSummaryCard(request, isDark),
                  const SizedBox(height: AppSpacing.xl),

                  const SectionHeader(title: 'Patient Information'),
                  _buildPatientMinimalCard(request, isDark),
                  const SizedBox(height: AppSpacing.xl),

                  const SectionHeader(title: 'Hospital Details'),
                  _buildHospitalCard(request, isDark),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Mocking distance data for presentation (assuming TravelTimeCard uses core styling internally)
                  const TravelTimeCard(minutes: 15, distanceKm: 4.2),
                  const SizedBox(height: AppSpacing.xl),

                  const SectionHeader(title: 'Eligibility Check'),
                  // Assuming EligibilityCard is fine, or wrap it if necessary.
                  const EligibilityCard(
                    isEligible: isEligible,
                    isAvailable: true,
                    isVerified: true,
                    passedCooldown: true,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  if (['AWAITING_RESPONSES', 'NOTIFICATIONS_SENT', 'DONORS_IDENTIFIED', 'SEARCHING']
                      .contains(request.status.toUpperCase()))
                    // Replaced standard action panel with Custom primary/secondary buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrimaryButton(
                          text: 'ACCEPT EMERGENCY',
                          icon: Icons.favorite,
                          onPressed: isEligible ? _handleAccept : null,
                          isLoading: _isAccepting,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SecondaryButton(
                          text: 'DECLINE',
                          onPressed: _handleDecline,
                        ),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlreadyAcceptedScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RedBankScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite, color: AppColors.primary, size: 80),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Already Accepted',
                    style: AppTypography.getTextTheme(isDark: isDark).headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Another donor has already accepted this emergency.\n\nThank you for being willing to donate and save a life. Your generosity means the world to us!',
                    textAlign: TextAlign.center,
                    style: AppTypography.getTextTheme(isDark: isDark).bodyLarge?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    text: 'RETURN TO DASHBOARD',
                    onPressed: () {
                      context.pop(); // Returns to dashboard
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(EmergencyRequestModel request, bool isDark) {
    return SurfaceCard(
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildDetailRow('Priority', request.priority, isDark, 
            statusType: request.priority == 'EMERGENCY' ? StatusType.error : StatusType.warning
          ),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow(
            'Blood Required', 
            '${request.unitsRequired} Units of ${request.bloodGroup.replaceAll('_POSITIVE', '+').replaceAll('_NEGATIVE', '-')}', 
            isDark,
            isHighlight: true
          ),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow('Component', request.emergencyType.replaceAll('_', ' '), isDark),
        ],
      ),
    );
  }

  Widget _buildPatientMinimalCard(EmergencyRequestModel request, bool isDark) {
    return SurfaceCard(
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(
            'For privacy reasons, only essential information is displayed until you accept the request.',
            style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow('Patient Initial', request.patientName?.isNotEmpty == true ? request.patientName![0] : 'U', isDark),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow('Age Group', 'Adult', isDark),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(EmergencyRequestModel request, bool isDark) {
    return SurfaceCard(
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildDetailRow('Hospital Name', request.hospitalName, isDark),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow('District', request.city ?? 'Unknown', isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {bool isHighlight = false, StatusType? statusType}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.getTextTheme(isDark: isDark).bodyMedium?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        if (statusType != null)
          StatusChip(label: value, type: statusType)
        else
          Text(
            value,
            style: AppTypography.getTextTheme(isDark: isDark).bodyLarge?.copyWith(
              color: isHighlight ? AppColors.primary : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
