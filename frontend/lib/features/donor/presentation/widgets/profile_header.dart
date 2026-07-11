import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import 'blood_group_badge.dart';
import 'availability_chip.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? profileImageUrl;
  final String bloodGroup;
  final String verificationLevel;
  final String availabilityStatus;

  const ProfileHeader({
    super.key,
    required this.name,
    this.profileImageUrl,
    required this.bloodGroup,
    required this.verificationLevel,
    required this.availabilityStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
          child: profileImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : null,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Icon(
                    verificationLevel != 'UNVERIFIED' ? Icons.verified : Icons.error_outline,
                    size: 16,
                    color: verificationLevel != 'UNVERIFIED'
                        ? Colors.blue // Or AppColors.info
                        : Theme.of(context).colorScheme.error,
                    semanticLabel: verificationLevel != 'UNVERIFIED' ? 'Verified Profile' : 'Unverified Profile',
                  ),
                  const SizedBox(width: 4),
                  Text(
                    verificationLevel.replaceAll('_', ' '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  BloodGroupBadge(bloodGroup: bloodGroup),
                  const SizedBox(width: AppSpacing.sm),
                  AvailabilityChip(status: availabilityStatus),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
