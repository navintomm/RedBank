import 'package:flutter/material.dart';

class AvailabilityChip extends StatelessWidget {
  final String status;

  const AvailabilityChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    String displayText;

    switch (status) {
      case 'AVAILABLE':
        chipColor = Colors.green; // Using standard semantic color mapping could be from Theme or AppColors.success
        displayText = 'Available';
        break;
      case 'UNAVAILABLE':
        chipColor = Colors.grey;
        displayText = 'Unavailable';
        break;
      case 'ON_COOLDOWN':
        chipColor = Colors.orange;
        displayText = 'On Cooldown';
        break;
      default:
        chipColor = Theme.of(context).colorScheme.outline;
        displayText = status;
    }

    return Chip(
      label: Text(
        displayText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
      backgroundColor: chipColor,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
