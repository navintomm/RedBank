import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/blood_group_helper.dart';

class BloodGroupBadge extends StatelessWidget {
  final String bloodGroup;

  const BloodGroupBadge({
    super.key,
    required this.bloodGroup,
  });

  Color _getBadgeColor() {
    return bloodGroup.contains('_POSITIVE') ? Colors.red : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: _getBadgeColor(),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        BloodGroupHelper.formatDisplay(bloodGroup),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
