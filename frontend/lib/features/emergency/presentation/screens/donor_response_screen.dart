import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/primary_button.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Acceptance'),
        content: const Text(
          'Are you sure you want to accept this emergency request? '
          'You will be expected to travel to the hospital immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('ACCEPT'),
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
    // Optional reason dialog
    final reasonController = TextEditingController();
    final shouldDecline = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Would you like to provide a reason? (Optional)'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Too far away',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('DECLINE', style: TextStyle(color: AppColors.error)),
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Emergency Request'),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          // If we encounter a hard page-load error that isn't a 409 action
          return ErrorStateWidget(
            errorMessage: 'Failed to load request data.',
            onRetry: () => ref.read(emergencyNotifierProvider.notifier).getRequestDetails(widget.requestId),
          );
        },
        data: (state) {
          final request = state.currentRequest;
          if (request == null) {
            return const Center(child: Text('Request not found.'));
          }

          // Mocking donor eligibility. In a real app this would come from a donor provider
          const isEligible = true;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EmergencyStatusBanner(request: request),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionTitle(title: 'Emergency Summary'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildSummaryCard(request, theme, isDark),
                      const SizedBox(height: AppSpacing.xl),

                      const SectionTitle(title: 'Patient Information'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPatientMinimalCard(request, theme, isDark),
                      const SizedBox(height: AppSpacing.xl),

                      const SectionTitle(title: 'Hospital Details'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildHospitalCard(request, theme, isDark),
                      const SizedBox(height: AppSpacing.md),
                      
                      // Mocking distance data for presentation
                      const TravelTimeCard(minutes: 15, distanceKm: 4.2),
                      const SizedBox(height: AppSpacing.xl),

                      const SectionTitle(title: 'Eligibility Check'),
                      const SizedBox(height: AppSpacing.sm),
                      const EligibilityCard(
                        isEligible: isEligible,
                        isAvailable: true,
                        isVerified: true,
                        passedCooldown: true,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      if (['AWAITING_RESPONSES', 'NOTIFICATIONS_SENT', 'DONORS_IDENTIFIED', 'SEARCHING']
                          .contains(request.status.toUpperCase()))
                        ResponseActionPanel(
                          isEligible: isEligible,
                          isLoading: _isAccepting,
                          onAccept: _handleAccept,
                          onDecline: _handleDecline,
                        ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlreadyAcceptedScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Update'),
        automaticallyImplyLeading: false, // Force them to use the button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: AppColors.primary, size: 80),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Already Accepted',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Another donor has already accepted this emergency.\n\nThank you for being willing to donate and save a life. Your generosity means the world to us!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                text: 'RETURN TO DASHBOARD',
                onPressed: () {
                  context.pop(); // Returns to dashboard since they were navigated here from a notification or list
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(EmergencyRequestModel request, ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildDetailRow('Priority', request.priority, theme, isDark, isHighlight: request.priority == 'EMERGENCY'),
            const Divider(),
            _buildDetailRow(
              'Blood Required', 
              '${request.unitsRequired} Units of ${request.bloodGroup.replaceAll('_POSITIVE', '+').replaceAll('_NEGATIVE', '-')}', 
              theme, 
              isDark,
              isHighlight: true
            ),
            const Divider(),
            _buildDetailRow('Component', request.emergencyType.replaceAll('_', ' '), theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientMinimalCard(EmergencyRequestModel request, ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              'For privacy reasons, only essential information is displayed until you accept the request.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow('Patient Initial', request.patientName?.isNotEmpty == true ? request.patientName![0] : 'U', theme, isDark),
            const Divider(),
            _buildDetailRow('Age Group', 'Adult', theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalCard(EmergencyRequestModel request, ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildDetailRow('Hospital Name', request.hospitalName, theme, isDark),
            const Divider(),
            _buildDetailRow('District', request.city ?? 'Unknown', theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme, bool isDark, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isHighlight ? AppColors.primary : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
