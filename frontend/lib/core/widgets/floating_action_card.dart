import 'package:flutter/material.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import 'glass_card.dart';

class FloatingActionCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const FloatingActionCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        boxShadow: AppShadows.floating,
      ),
      child: GlassCard(
        borderRadius: AppSpacing.borderRadiusPill,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        onTap: onTap,
        child: child,
      ),
    );
  }
}
