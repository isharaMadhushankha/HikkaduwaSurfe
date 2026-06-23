import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_tile.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      context.read<NotificationProvider>().loadNotifications(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
        actions: [
          if (notifProvider.hasUnread)
            TextButton(
              onPressed: () {
                notifProvider.markAllAsRead(authProvider.userId);
              },
              child: const Text(
                'Read All',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (notifProvider.notifications.isNotEmpty)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All'),
                    content: const Text(
                      'Are you sure you want to delete all notifications?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          notifProvider
                              .deleteAllNotifications(authProvider.userId);
                        },
                        child: const Text(
                          'Delete All',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: notifProvider.isLoading
          ? const LoadingWidget()
          : notifProvider.notifications.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.notifications_off_outlined,
                  title: 'No Notifications',
                  subtitle: 'You\'re all caught up!',
                )
              : RefreshIndicator(
                  onRefresh: () => notifProvider
                      .loadNotifications(authProvider.userId),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifProvider.notifications.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final notification =
                          notifProvider.notifications[index];
                      return NotificationTile(
                        notification: notification,
                        onTap: () {
                          // Mark as read
                          if (!notification.isRead) {
                            notifProvider.markAsRead(notification.id);
                          }
                          // Navigate to booking if linked
                          if (notification.bookingId != null) {
                            context.go(
                              '/user/booking/${notification.bookingId}',
                            );
                          }
                        },
                        onDismiss: () {
                          notifProvider
                              .deleteNotification(notification.id);
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
