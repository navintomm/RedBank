import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';

Future<T?> showMedicalBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: isDark ? Colors.black87 : Colors.black54,
    builder: (BuildContext context) {
      return SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            margin: const EdgeInsets.only(top: AppSpacing.xxl),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: AppConstants.glassBlur, sigmaY: AppConstants.glassBlur),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface1Dark : AppColors.surface1Light,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white12 : Colors.white70,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      // Drag handle
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                          borderRadius: AppSpacing.borderRadiusPill,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (title != null) ...[
                        Text(
                          title,
                          style: AppTypography.getTextTheme(isDark: isDark).headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Divider(
                          height: 1,
                          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                        ),
                      ],
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: SafeArea(top: false, child: child),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
