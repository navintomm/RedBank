import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

enum HistorySortOrder { newestFirst, oldestFirst }

class HistoryFilterOptions {
  final String status;
  final HistorySortOrder sortOrder;

  const HistoryFilterOptions({
    this.status = 'All',
    this.sortOrder = HistorySortOrder.newestFirst,
  });

  HistoryFilterOptions copyWith({
    String? status,
    HistorySortOrder? sortOrder,
  }) {
    return HistoryFilterOptions(
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class HistoryFilterSheet extends StatefulWidget {
  final HistoryFilterOptions currentOptions;

  const HistoryFilterSheet({
    super.key,
    required this.currentOptions,
  });

  @override
  State<HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<HistoryFilterSheet> {
  late String _selectedStatus;
  late HistorySortOrder _selectedSort;

  final List<String> _statusOptions = [
    'All',
    'Completed',
    'Cancelled',
    'Expired',
    'Failed',
    'No Show'
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentOptions.status;
    _selectedSort = widget.currentOptions.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter History',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Status', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _statusOptions.map((status) {
                final isSelected = _selectedStatus == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedStatus = status);
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Sort Order', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<HistorySortOrder>(
                    title: const Text('Newest'),
                    value: HistorySortOrder.newestFirst,
                    groupValue: _selectedSort,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSort = val);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<HistorySortOrder>(
                    title: const Text('Oldest'),
                    value: HistorySortOrder.oldestFirst,
                    groupValue: _selectedSort,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSort = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(const HistoryFilterOptions());
                    },
                    child: const Text('RESET'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(
                        HistoryFilterOptions(
                          status: _selectedStatus,
                          sortOrder: _selectedSort,
                        ),
                      );
                    },
                    child: const Text('APPLY'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
