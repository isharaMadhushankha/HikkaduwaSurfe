// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/notification_model.dart';
import '../utils/helpers.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  IconData _getIcon() {
    switch (notification.type) {
      case 'booking_request':
        return Icons.calendar_today;
      case 'booking_confirmed':
        return Icons.check_circle;
      case 'booking_cancelled':
        return Icons.cancel;
      case 'review_received':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case 'booking_request':
        return AppTheme.primaryColor;
      case 'booking_confirmed':
        return AppTheme.successColor;
      case 'booking_cancelled':
        return AppTheme.errorColor;
      case 'review_received':
        return AppTheme.accentColor;
      default:
        return AppTheme.greyText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: notification.isRead
              ? Colors.transparent
              : AppTheme.primaryColor.withOpacity(0.04),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- ICON ----------
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getIconColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              // ---------- CONTENT ----------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.greyText,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Helpers.timeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
