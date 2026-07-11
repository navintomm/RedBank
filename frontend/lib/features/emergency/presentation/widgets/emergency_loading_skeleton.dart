import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class EmergencyLoadingSkeleton extends StatefulWidget {
  final int itemCount;

  const EmergencyLoadingSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  State<EmergencyLoadingSkeleton> createState() => _EmergencyLoadingSkeletonState();
}

class _EmergencyLoadingSkeletonState extends State<EmergencyLoadingSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: _opacity,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: baseColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 60, height: 24, color: baseColor),
                    Container(width: 80, height: 20, color: baseColor),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(width: double.infinity, height: 16, color: baseColor),
                const SizedBox(height: AppSpacing.xs),
                Container(width: 150, height: 16, color: baseColor),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Container(width: 100, height: 36, decoration: BoxDecoration(color: baseColor, borderRadius: AppSpacing.borderRadiusSm)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
