import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../domain/emergency_models.dart';
import '../../providers/emergency_provider.dart';

import '../widgets/history_card.dart';
import '../widgets/history_search_bar.dart';
import '../widgets/history_filter_sheet.dart';
import '../widgets/history_empty_state.dart';

class EmergencyHistoryScreen extends ConsumerStatefulWidget {
  const EmergencyHistoryScreen({super.key});

  @override
  ConsumerState<EmergencyHistoryScreen> createState() => _EmergencyHistoryScreenState();
}

class _EmergencyHistoryScreenState extends ConsumerState<EmergencyHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  HistoryFilterOptions _filterOptions = const HistoryFilterOptions();
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emergencyNotifierProvider.notifier).loadMyRequests();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<HistoryFilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HistoryFilterSheet(currentOptions: _filterOptions),
    );

    if (result != null) {
      setState(() {
        _filterOptions = result;
      });
    }
  }

  List<EmergencyRequestModel> _getFilteredRequests(List<EmergencyRequestModel> requests) {
    var filtered = requests.toList();

    // Text Search
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((req) {
        return req.hospitalName.toLowerCase().contains(query) ||
               req.bloodGroup.toLowerCase().contains(query) ||
               req.emergencyType.toLowerCase().contains(query);
      }).toList();
    }

    // Status Filter
    if (_filterOptions.status != 'All') {
      final targetStatus = _filterOptions.status.toUpperCase().replaceAll(' ', '_');
      filtered = filtered.where((req) => req.status.toUpperCase() == targetStatus).toList();
    }

    // Sort Order
    filtered.sort((a, b) {
      if (_filterOptions.sortOrder == HistorySortOrder.newestFirst) {
        return b.createdAt.compareTo(a.createdAt);
      } else {
        return a.createdAt.compareTo(b.createdAt);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(emergencyNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Emergency History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: HistorySearchBar(
              controller: _searchController,
              onFilterTap: _openFilterSheet,
              hasActiveFilters: _filterOptions.status != 'All',
            ),
          ),
          Expanded(
            child: stateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorStateWidget(
                errorMessage: 'Failed to load history.',
                onRetry: () => ref.read(emergencyNotifierProvider.notifier).loadMyRequests(),
              ),
              data: (state) {
                final allRequests = state.myRequests;
                final filteredRequests = _getFilteredRequests(allRequests);

                if (allRequests.isEmpty) {
                  return const HistoryEmptyState(isFiltering: false);
                }

                if (filteredRequests.isEmpty) {
                  return HistoryEmptyState(
                    isFiltering: true,
                    onClearFilters: () {
                      _searchController.clear();
                      setState(() {
                        _filterOptions = const HistoryFilterOptions();
                      });
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(emergencyNotifierProvider.notifier).loadMyRequests();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    itemCount: filteredRequests.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      return HistoryCard(
                        request: request,
                        onTap: () {
                          // Navigating to details screen. 
                          // In a full routing setup, this might be context.pushNamed
                          context.push('/emergency/${request.id}');
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
