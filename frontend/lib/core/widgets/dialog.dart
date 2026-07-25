import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../theme/app_spacing.dart';
import '../theme/app_shadows.dart';

Future<T?> showMedicalDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Medical Dialog',
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox();
    },
    transitionBuilder: (context, animation, secondaryAnimation, _) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.all(AppSpacing.xl),
            child: ClipRRect(
              borderRadius: AppSpacing.borderRadiusLg,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: AppConstants.glassBlur, sigmaY: AppConstants.glassBlur),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface1Dark : AppColors.surface1Light,
                    borderRadius: AppSpacing.borderRadiusLg,
                    boxShadow: AppShadows.large,
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                      width: 1,
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
