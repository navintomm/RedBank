import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/redbank_scaffold.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/otp_input.dart';
import '../../../../core/widgets/icon_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;

  const OtpVerificationScreen({super.key, required this.verificationId});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
                'Verify OTP',
                style: AppTypography.getTextTheme(isDark: isDark).headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter the 6-digit code sent to your phone.',
                style: AppTypography.getTextTheme(isDark: isDark).bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SurfaceCard(
                elevated: true,
                child: Column(
                  children: [
                    OtpInput(
                      length: 6,
                      onCompleted: (otp) {
                        // Handle automatic submission
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      text: 'Verify',
                      onPressed: () {
                        // Trigger verification
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildResendButton(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton(bool isDark) {
    if (_secondsRemaining > 0) {
      return Text(
        'Resend Code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
        style: AppTypography.getTextTheme(isDark: isDark).labelLarge?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        // Trigger resend logic
        _startTimer();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          'Resend Code',
          style: AppTypography.getTextTheme(isDark: isDark).labelLarge?.copyWith(
            color: isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
