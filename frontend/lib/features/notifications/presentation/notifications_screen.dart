import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/redbank_scaffold.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/services/notifications/notification_service.dart';
import 'widgets/notification_card.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late int _initialUnreadCount;

  @override
  void initState() {
    super.initState();
    _initialUnreadCount = ref.read(notificationProvider).unreadCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);

    return RedBankScaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: notificationState.historyCache.isEmpty
          ? const EmptyStateWidget(
              title: 'No Notifications',
              message: 'You have no new alerts at this time.',
              icon: Icons.notifications_off_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: notificationState.historyCache.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final message = notificationState.historyCache[index];
                final isRead = index >= _initialUnreadCount;

                return NotificationCard(
                  message: message,
                  isRead: isRead,
                  onTap: () {
                    // Tap handling if necessary
                  },
                );
              },
            ),
    );
  }
}
