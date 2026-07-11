import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/information_card.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/donor_provider.dart';
import 'widgets/availability_status_card.dart';

class AvailabilitySettingsScreen extends ConsumerStatefulWidget {
  const AvailabilitySettingsScreen({super.key});

  @override
  ConsumerState<AvailabilitySettingsScreen> createState() => _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState extends ConsumerState<AvailabilitySettingsScreen> {
  bool _isLoading = false;

  Future<void> _handleToggleAvailability(String currentStatus) async {
    final newStatus = currentStatus == 'AVAILABLE' ? 'UNAVAILABLE' : 'AVAILABLE';
    
    final shouldChange = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Availability'),
        content: Text(
          newStatus == 'AVAILABLE'
              ? 'Are you sure you want to mark yourself as AVAILABLE? You will start receiving emergency requests.'
              : 'Are you sure you want to mark yourself as UNAVAILABLE? You will no longer receive emergency requests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (shouldChange != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(donorProfileProvider.notifier);
      await notifier.updateAvailability(newStatus);

      final state = ref.read(donorProfileProvider);
      if (state.hasError) {
        throw state.error!;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final donorState = ref.watch(donorProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Settings'),
      ),
      body: donorState.when(
        data: (profile) {
          if (profile == null) {
            return const EmptyStateWidget(
              message: 'You need to create a donor profile before managing availability.',
              icon: Icons.person_off_outlined,
            );
          }

          final isOnCooldown = profile.availabilityStatus == 'ON_COOLDOWN';

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AvailabilityStatusCard(
                status: profile.availabilityStatus,
                lastDonationDate: profile.lastDonationDate,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              if (isOnCooldown)
                const InformationCard(
                  title: 'Manual Toggle Disabled',
                  child: Text(
                    'You cannot manually change your availability while on a cooldown period for your own safety.',
                  ),
                )
              else
                InformationCard(
                  title: 'Manage Availability',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Toggle your status below. If you are travelling, sick, or simply do not wish to be disturbed, please set your status to Unavailable.',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        text: profile.availabilityStatus == 'AVAILABLE'
                            ? 'Mark as Unavailable'
                            : 'Mark as Available',
                        isLoading: _isLoading,
                        onPressed: () => _handleToggleAvailability(profile.availabilityStatus),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [
            LoadingSkeleton(height: 150),
            SizedBox(height: AppSpacing.lg),
            LoadingSkeleton(height: 200),
          ],
        ),
        error: (error, _) => ErrorStateWidget(
          errorMessage: error.toString(),
          onRetry: () => ref.invalidate(donorProfileProvider),
        ),
      ),
    );
  }
}
