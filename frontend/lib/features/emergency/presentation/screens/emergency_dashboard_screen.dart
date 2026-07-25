import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/redbank_scaffold.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/icon_button.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/emergency_models.dart';
import '../../providers/emergency_provider.dart';
import '../widgets/emergency_summary_card.dart';

class EmergencyDashboardScreen extends ConsumerStatefulWidget {
  const EmergencyDashboardScreen({super.key});

  @override
  ConsumerState<EmergencyDashboardScreen> createState() => _EmergencyDashboardScreenState();
}

class _EmergencyDashboardScreenState extends ConsumerState<EmergencyDashboardScreen> {
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emergencyNotifierProvider.notifier).loadActiveEmergencies();
      ref.read(emergencyNotifierProvider.notifier).loadMyRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final emergencyStateAsync = ref.watch(emergencyNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RedBankScaffold(
      // Floating Bottom Navigation
      bottomNavigationBar: _buildFloatingBottomNav(isDark),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(emergencyNotifierProvider.notifier).loadActiveEmergencies();
          await ref.read(emergencyNotifierProvider.notifier).loadMyRequests();
        },
        child: CustomScrollView(
          slivers: [
            // Floating SliverAppBar (Greeting & Avatar)
            SliverAppBar(
              expandedHeight: 80,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: isDark ? AppColors.backgroundDark.withOpacity(0.8) : AppColors.backgroundLight.withOpacity(0.8),
                ),
                titlePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning,',
                          style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          'Navin', // Hardcoded for demo, normally from AuthProvider
                          style: AppTypography.getTextTheme(isDark: isDark).titleMedium,
                        ),
                      ],
                    ),
                    MedicalIconButton(
                      icon: Icons.person_outline,
                      hasBackground: true,
                      isGlass: true,
                      size: 40,
                      onPressed: () {
                        // Profile tap
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // State handling content
            emergencyStateAsync.when(
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      SkeletonLoader(height: 160, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(child: SkeletonLoader(height: 80, borderRadius: BorderRadius.circular(AppSpacing.radiusLg))),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: SkeletonLoader(height: 80, borderRadius: BorderRadius.circular(AppSpacing.radiusLg))),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SkeletonLoader(height: 120, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                    ],
                  ),
                ),
              ),
              error: (error, stackTrace) => SliverToBoxAdapter(
                child: ErrorStateWidget(
                  message: 'Failed to load dashboard data. Please try again.',
                  onRetry: () {
                    ref.read(emergencyNotifierProvider.notifier).loadActiveEmergencies();
                    ref.read(emergencyNotifierProvider.notifier).loadMyRequests();
                  },
                ),
              ),
              data: (state) {
                final active = state.activeEmergencies;
                final myRequests = state.myRequests;

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          
                          // Hero Section (Request Blood CTA)
                          _buildHeroSection(isDark, active.length),
                          const SizedBox(height: AppSpacing.xl),
                          
                          // Quick Actions
                          const SectionHeader(title: 'Quick Actions'),
                          _buildQuickActions(context, isDark),
                          const SizedBox(height: AppSpacing.xl),
                          
                          // Recent Activity / Active Emergencies
                          const SectionHeader(title: 'Nearby Emergencies'),
                          _buildActiveEmergenciesFeed(context, active),
                          
                          // Bottom Padding for FAB/NavBar clearance
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark, int activeCount) {
    return SurfaceCard(
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.emergency,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                size: 32,
              ),
              if (activeCount > 0)
                StatusChip(
                  label: '$activeCount Active Near You',
                  type: StatusType.error,
                  icon: Icons.warning_amber_rounded,
                )
              else
                const StatusChip(
                  label: 'Area Secure',
                  type: StatusType.success,
                  icon: Icons.check_circle_outline,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Need Blood Urgently?',
            style: AppTypography.getTextTheme(isDark: isDark).headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Create a request to alert donors in your immediate vicinity.',
            style: AppTypography.getTextTheme(isDark: isDark).bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            text: 'Request Blood Now',
            icon: Icons.bloodtype,
            onPressed: () => context.push('/emergencies/create'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.list_alt_rounded,
            label: 'My Requests',
            isDark: isDark,
            onTap: () => context.push('/emergencies/my-requests'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.history_rounded,
            label: 'History',
            isDark: isDark,
            onTap: () => context.push('/emergencies/history'),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveEmergenciesFeed(BuildContext context, List<EmergencyRequestModel> active) {
    if (active.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Active Emergencies',
        message: 'There are currently no active emergency blood requests in your area.',
        icon: Icons.health_and_safety_outlined,
      );
    }

    return Column(
      children: active.map((request) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          // We wrap the existing EmergencySummaryCard inside our new soft design constraints
          // Assuming EmergencySummaryCard hasn't been visually updated yet, 
          // we might just render it directly for now, or wrap it.
          // Since we shouldn't touch business logic in EmergencySummaryCard, we render it directly.
          child: EmergencySummaryCard(
            request: request,
            onTap: () => context.push('/emergencies/${request.id}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFloatingBottomNav(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xl,
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home', isDark),
            _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Map', isDark),
            _buildNavItem(2, Icons.person_rounded, Icons.person_outline, 'Profile', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, bool isDark) {
    final isSelected = _bottomNavIndex == index;
    final color = isSelected 
        ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return GestureDetector(
      onTap: () => setState(() => _bottomNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.getTextTheme(isDark: isDark).labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      elevated: false,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.secondaryDark : AppColors.secondaryLight).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.getTextTheme(isDark: isDark).labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
