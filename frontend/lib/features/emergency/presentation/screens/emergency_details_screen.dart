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
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/status_chip.dart';
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

    return RedBankScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Emergency Details'),
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: MedicalIconButton(
            icon: Icons.arrow_back,
            isGlass: true,
            hasBackground: true,
            onPressed: () => context.pop(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: MedicalIconButton(
              icon: Icons.refresh,
              isGlass: true,
              hasBackground: true,
              onPressed: () => ref.read(emergencyNotifierProvider.notifier).getRequestDetails(widget.requestId),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorStateWidget(
            message: 'Failed to load details. Please try again.',
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
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // We keep the banner if it fits the design, or wrap it in a SurfaceCard
                  EmergencyStatusBanner(request: request),
                  const SizedBox(height: AppSpacing.lg),
                  
                  const SectionHeader(title: 'Timeline'),
                  SurfaceCard(
                    elevated: true,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.sm),
                    child: EmergencyTimeline(currentStatus: request.status),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  const SectionHeader(title: 'Emergency Summary'),
                  _buildSummarySection(request, isDark),
                  const SizedBox(height: AppSpacing.xl),
                  
                  const SectionHeader(title: 'Patient Information'),
                  _buildPatientSection(request, isDark),
                  const SizedBox(height: AppSpacing.xl),
                  
                  const SectionHeader(title: 'Hospital Details'),
                  _buildHospitalSection(request, isDark),
                  const SizedBox(height: AppSpacing.xl),

                  if (hasDonor) ...[
                    const SectionHeader(title: 'Assigned Donor'),
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
                    const SectionHeader(title: 'Assigned Donor'),
                    _buildWaitingState(isDark),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  _buildActionButtons(request, isTerminal, isDark),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummarySection(EmergencyRequestModel request, bool isDark) {
    return SurfaceCard(
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildDetailRow('Request ID', request.id.split('-').first.toUpperCase(), isDark),
          const Divider(height: AppSpacing.xl),
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

  Widget _buildPatientSection(EmergencyRequestModel request, bool isDark) {
    return SurfaceCard(
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildDetailRow('Name', request.patientName ?? 'Confidential', isDark),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow('Age', 'Not Provided', isDark),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow('Gender', 'Not Provided', isDark),
        ],
      ),
    );
  }

  Widget _buildHospitalSection(EmergencyRequestModel request, bool isDark) {
    return SurfaceCard(
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildDetailRow('Hospital Name', request.hospitalName, isDark),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow('Address', request.hospitalAddress ?? 'Not provided', isDark),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow('City', request.city ?? 'Not provided', isDark),
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

  Widget _buildWaitingState(bool isDark) {
    return SurfaceCard(
      elevated: false,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waiting for Donor',
                  style: AppTypography.getTextTheme(isDark: isDark).titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We are actively matching nearby eligible donors to this request.',
                  style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
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

  Widget _buildActionButtons(EmergencyRequestModel request, bool isTerminal, bool isDark) {
    if (isTerminal) {
      final isSuccess = request.status == 'COMPLETED';
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: isSuccess ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isSuccess ? 'This emergency has been successfully resolved.' : 'Request terminated: ${request.status}',
                style: AppTypography.getTextTheme(isDark: isDark).labelLarge?.copyWith(
                  color: isSuccess ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SecondaryButton(
        text: 'CANCEL REQUEST',
        icon: Icons.cancel_outlined,
        onPressed: _cancelRequest,
        isError: true,
      );
    }
  }
}
