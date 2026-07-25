import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/redbank_scaffold.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/medical_text_field.dart';
import '../../../../core/widgets/icon_button.dart';

class PhoneLoginScreen extends StatelessWidget {
  const PhoneLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RedBankScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: MedicalIconButton(
            icon: Icons.arrow_back,
            isGlass: true,
            hasBackground: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Enter Phone Number',
                style: AppTypography.getTextTheme(isDark: isDark).headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We will send a 6-digit verification code to confirm your identity.',
                style: AppTypography.getTextTheme(isDark: isDark).bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SurfaceCard(
                elevated: true,
                child: Column(
                  children: [
                    const MedicalTextField(
                      labelText: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      hintText: '+1 (555) 000-0000',
                      autofillHints: [AutofillHints.telephoneNumber],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      text: 'Send Code',
                      onPressed: () {
                        // Trigger logic
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
