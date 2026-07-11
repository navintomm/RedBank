import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/emergency_models.dart';
import '../../providers/emergency_provider.dart';
import '../widgets/emergency_empty_state.dart';
import '../widgets/emergency_loading_skeleton.dart';
import '../widgets/emergency_statistics_card.dart';
import '../widgets/emergency_summary_card.dart';

class EmergencyDashboardScreen extends ConsumerStatefulWidget {
  const EmergencyDashboardScreen({super.key});

  @override
  ConsumerState<EmergencyDashboardScreen> createState() => _EmergencyDashboardScreenState();
}

class _EmergencyDashboardScreenState extends ConsumerState<EmergencyDashboardScreen> {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Emergency Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(emergencyNotifierProvider.notifier).loadActiveEmergencies();
              ref.read(emergencyNotifierProvider.notifier).loadMyRequests();
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(emergencyNotifierProvider.notifier).loadActiveEmergencies();
          await ref.read(emergencyNotifierProvider.notifier).loadMyRequests();
        },
        child: emergencyStateAsync.when(
          loading: () => const SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: EmergencyLoadingSkeleton(itemCount: 4),
          ),
          error: (error, stackTrace) => ErrorStateWidget(
            errorMessage: 'Failed to load dashboard data. Please try again.',
            onRetry: () {
              ref.read(emergencyNotifierProvider.notifier).loadActiveEmergencies();
              ref.read(emergencyNotifierProvider.notifier).loadMyRequests();
            },
          ),
          data: (state) {
            final active = state.activeEmergencies;
            final myRequests = state.myRequests;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildQuickActions(context),
                      const SizedBox(height: AppSpacing.lg),
                      const SectionTitle(title: 'Statistics'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildStatistics(active, myRequests),
                      const SizedBox(height: AppSpacing.lg),
                      const SectionTitle(title: 'Active Emergencies'),
                      const SizedBox(height: AppSpacing.sm),
                    ]),
                  ),
                ),
                active.isEmpty
                    ? const SliverToBoxAdapter(
                        child: EmergencyEmptyState(
                          title: 'No Active Emergencies',
                          subtitle: 'There are currently no active emergency blood requests in your area.',
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final request = active[index];
                              return EmergencySummaryCard(
                                request: request,
                                onTap: () => context.push('/emergencies/${request.id}'),
                              );
                            },
                            childCount: active.length,
                          ),
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Quick Actions'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_alert,
                label: 'Create Request',
                color: AppColors.primary,
                onTap: () => context.push('/emergencies/create'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.list_alt,
                label: 'My Requests',
                color: AppColors.secondary,
                onTap: () => context.push('/emergencies/my-requests'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.history,
                label: 'History',
                color: AppColors.warning,
                onTap: () => context.push('/emergencies/history'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics(List<EmergencyRequestModel> active, List<EmergencyRequestModel> myRequests) {
    // In a real app, these would come from a dedicated stats endpoint
    final totalActive = active.length;
    final totalCompleted = myRequests.where((r) => r.status == 'COMPLETED').length;
    final totalCancelled = myRequests.where((r) => r.status == 'CANCELLED').length;
    final totalRequests = myRequests.length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: EmergencyStatisticsCard(
                title: 'Total Requests',
                count: totalRequests,
                icon: Icons.folder_open,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: EmergencyStatisticsCard(
                title: 'Active',
                count: totalActive,
                icon: Icons.local_fire_department,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: EmergencyStatisticsCard(
                title: 'Completed',
                count: totalCompleted,
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: EmergencyStatisticsCard(
                title: 'Cancelled',
                count: totalCancelled,
                icon: Icons.cancel_outlined,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppSpacing.borderRadiusMd,
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
