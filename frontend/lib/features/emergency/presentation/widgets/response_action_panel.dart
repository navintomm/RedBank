import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';

class ResponseActionPanel extends StatelessWidget {
  final bool isEligible;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ResponseActionPanel({
    super.key,
    required this.isEligible,
    this.isLoading = false,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        PrimaryButton(
          text: 'ACCEPT EMERGENCY',
          onPressed: isEligible && !isLoading ? onAccept : null,
          isLoading: isLoading,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: isLoading ? null : onDecline,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: const RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSm,
              ),
            ),
            child: const Text(
              'DECLINE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
