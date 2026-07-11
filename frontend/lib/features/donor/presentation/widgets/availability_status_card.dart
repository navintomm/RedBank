import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import 'availability_chip.dart';

class AvailabilityStatusCard extends StatelessWidget {
  final String status;
  final DateTime? lastDonationDate;

  const AvailabilityStatusCard({
    super.key,
    required this.status,
    this.lastDonationDate,
  });

  String _getEligibilityMessage() {
    if (status == 'ON_COOLDOWN' && lastDonationDate != null) {
      final eligibleDate = lastDonationDate!.add(const Duration(days: 90));
      return "You are currently on a 90-day cooldown period following your last donation. You will be eligible to donate again on \${eligibleDate.year}-\${eligibleDate.month.toString().padLeft(2, '0')}-\${eligibleDate.day.toString().padLeft(2, '0')}.";
    } else if (status == 'UNAVAILABLE') {
      return 'You are currently marked as unavailable. Emergency requests will not be routed to you.';
    } else if (status == 'AVAILABLE') {
      return 'You are available to donate. You may receive emergency requests from nearby hospitals or patients.';
    }
    return 'Status unknown.';
  }

  IconData _getStatusIcon() {
    if (status == 'AVAILABLE') return Icons.check_circle_outline;
    if (status == 'ON_COOLDOWN') return Icons.hourglass_bottom;
    return Icons.do_not_disturb_alt;
  }

  Color _getStatusColor(BuildContext context) {
    if (status == 'AVAILABLE') return Colors.green;
    if (status == 'ON_COOLDOWN') return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: statusColor.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: statusColor,
                  size: 28,
                  semanticLabel: 'Status Icon',
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Current Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                AvailabilityChip(status: status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _getEligibilityMessage(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
