import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/emergency_models.dart';
import '../../providers/emergency_provider.dart';
import '../widgets/emergency_status_banner.dart';
import '../widgets/emergency_timeline.dart';
import '../widgets/assigned_donor_card.dart';

class EmergencyDetailsScreen extends ConsumerStatefulWidget {
  final String requestId;

  const EmergencyDetailsScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<EmergencyDetailsScreen> createState() => _EmergencyDetailsScreenState();
}

class _EmergencyDetailsScreenState extends ConsumerState<EmergencyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emergencyNotifierProvider.notifier).getRequestDetails(widget.requestId);
    });
  }

  void _cancelRequest() async {
    // In a real app, this might show a dialog asking for cancel reason
    final success = await ref.read(emergencyNotifierProvider.notifier).cancelRequest(widget.requestId, 'NO_LONGER_NEEDED');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled successfully'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(emergencyNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Emergency Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: () => ref.read(emergencyNotifierProvider.notifier).getRequestDetails(widget.requestId),
          )
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateWidget(
          errorMessage: 'Failed to load details. Please try again.',
          onRetry: () => ref.read(emergencyNotifierProvider.notifier).getRequestDetails(widget.requestId),
        ),
        data: (state) {
          final request = state.currentRequest;
          if (request == null) {
            return const Center(child: Text('Request not found.'));
          }

          final isTerminal = ['COMPLETED', 'CANCELLED', 'FAILED', 'EXPIRED', 'NO_SHOW'].contains(request.status.toUpperCase());
          final hasDonor = ['ACCEPTED', 'DONOR_TRAVELLING', 'ARRIVED', 'DONATION_IN_PROGRESS'].contains(request.status.toUpperCase());

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
                      _buildSummarySection(request, theme, isDark),
                      const SizedBox(height: AppSpacing.xl),
                      _buildPatientSection(request, theme, isDark),
                      const SizedBox(height: AppSpacing.xl),
                      _buildHospitalSection(request, theme, isDark),
                      const SizedBox(height: AppSpacing.xl),
                      
                      const SectionTitle(title: 'Timeline'),
                      const SizedBox(height: AppSpacing.sm),
                      EmergencyTimeline(currentStatus: request.status),
                      const SizedBox(height: AppSpacing.xl),

                      if (hasDonor) ...[
                        const SectionTitle(title: 'Assigned Donor'),
                        const SizedBox(height: AppSpacing.sm),
                        // Mocking assignment wrapper since the endpoint currently doesn't inline full assignment data
                        AssignedDonorCard(
                          assignment: EmergencyAssignmentModel(
                            id: 'dummy-id',
                            emergencyRequestId: request.id,
                            donorId: 'dummy-donor',
                            estimatedArrival: DateTime.now().add(const Duration(minutes: 15)),
                          ),
                          bloodGroup: request.bloodGroup.replaceAll('_POSITIVE', '+').replaceAll('_NEGATIVE', '-'),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ] else if (!isTerminal) ...[
                        const SectionTitle(title: 'Assigned Donor'),
                        const SizedBox(height: AppSpacing.sm),
                        _buildWaitingState(isDark),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      _buildActionButtons(request, isTerminal),
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

  Widget _buildSummarySection(EmergencyRequestModel request, ThemeData theme, bool isDark) {
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
            _buildDetailRow('Request ID', request.id.split('-').first.toUpperCase(), theme, isDark),
            const Divider(),
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

  Widget _buildPatientSection(EmergencyRequestModel request, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Patient Information'),
        const SizedBox(height: AppSpacing.sm),
        Card(
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
                _buildDetailRow('Name', request.patientName ?? 'Confidential', theme, isDark),
                const Divider(),
                _buildDetailRow('Age', 'Not Provided', theme, isDark), // Not in backend payload
                const Divider(),
                _buildDetailRow('Gender', 'Not Provided', theme, isDark), // Not in backend payload
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalSection(EmergencyRequestModel request, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Hospital Information'),
        const SizedBox(height: AppSpacing.sm),
        Card(
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
                _buildDetailRow('Address', request.hospitalAddress ?? 'Not provided', theme, isDark),
                const Divider(),
                _buildDetailRow('City', request.city ?? 'Not provided', theme, isDark),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildWaitingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Waiting for Donor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'We are actively matching nearby eligible donors to this request.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(EmergencyRequestModel request, bool isTerminal) {
    if (isTerminal) {
      if (request.status == 'COMPLETED') {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.success),
          ),
          child: const Center(
            child: Text(
              'This emergency has been successfully resolved.',
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.error),
          ),
          child: Center(
            child: Text(
              'Request terminated: ${request.status}',
              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } else {
      // Show cancel button if request is active
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _cancelRequest,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
          child: const Text('CANCEL REQUEST'),
        ),
      );
    }
  }
}
