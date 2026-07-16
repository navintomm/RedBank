import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/information_card.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../domain/donor_models.dart';
import '../providers/donor_provider.dart';
import 'edit_donor_profile_screen.dart';
import 'widgets/profile_header.dart';

class DonorProfileScreen extends ConsumerWidget {
  const DonorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donorState = ref.watch(donorProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Profile'),
          actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditDonorProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate the provider to force a refresh
          ref.invalidate(donorProfileProvider);
          // Wait for the new future to resolve before dismissing the indicator
          try {
            await ref.read(donorProfileProvider.future);
          } catch (_) {
            // Ignore refresh errors here, UI will handle error state
          }
        },
        child: donorState.when(
          data: (profile) {
            if (profile == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  EmptyStateWidget(
                    message: 'You have not set up a donor profile yet.\nTap Edit to get started.',
                    icon: Icons.person_add_alt_1_outlined,
                  ),
                ],
              );
            }
            return _buildProfileContent(context, profile);
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ErrorStateWidget(
                errorMessage: error.toString(),
                onRetry: () => ref.invalidate(donorProfileProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, DonorProfileDto profile) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        ProfileHeader(
          name: 'Red Bank Hero', // Placeholder, in a real app fetch from Auth layer
          profileImageUrl: profile.profileImageUrl,
          bloodGroup: profile.bloodGroup,
          verificationLevel: profile.verificationLevel,
          availabilityStatus: profile.availabilityStatus,
        ),
        const SizedBox(height: AppSpacing.lg),
        
        InformationCard(
          title: 'Personal Information',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, 'Gender', profile.gender ?? 'Not specified'),
              const SizedBox(height: AppSpacing.xs),
              _buildInfoRow(context, 'Date of Birth', _formatDate(profile.dateOfBirth)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        InformationCard(
          title: 'Contact Information',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, 'City', profile.city ?? 'Not specified'),
              const SizedBox(height: AppSpacing.xs),
              _buildInfoRow(context, 'District', profile.district ?? 'Not specified'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        InformationCard(
          title: 'Medical Information',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, 'Weight (kg)', profile.weight?.toStringAsFixed(1) ?? 'Not specified'),
              const SizedBox(height: AppSpacing.xs),
              _buildInfoRow(context, 'Medical Notes', profile.medicalNotes ?? 'None'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        InformationCard(
          title: 'Donation Information',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, 'Last Donation', _formatDate(profile.lastDonationDate)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        LoadingSkeleton(height: 100),
        SizedBox(height: AppSpacing.lg),
        LoadingSkeleton(height: 120),
        SizedBox(height: AppSpacing.md),
        LoadingSkeleton(height: 120),
        SizedBox(height: AppSpacing.md),
        LoadingSkeleton(height: 120),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not specified';
    // Simple fallback date formatting since intl is not guaranteed to be installed yet
    return "\${date.year}-\${date.month.toString().padLeft(2, '0')}-\${date.day.toString().padLeft(2, '0')}";
  }
}
