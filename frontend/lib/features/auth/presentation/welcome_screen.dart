import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/redbank_scaffold.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RedBankScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  Icons.bloodtype_outlined,
                  size: 100,
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SurfaceCard(
                elevated: true, // Elevates the card to distinguish it from the background
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Save a Life Today',
                      textAlign: TextAlign.center,
                      style: AppTypography.getTextTheme(isDark: isDark).headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Join the RedBank network and get notified when someone near you needs help.',
                      textAlign: TextAlign.center,
                      style: AppTypography.getTextTheme(isDark: isDark).bodyLarge?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      text: 'Continue with Phone',
                      icon: Icons.phone_outlined,
                      onPressed: () {
                        // Navigate to Phone Login
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
