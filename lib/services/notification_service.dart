import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _client = SupabaseConfig.client;
  RealtimeChannel? _channel;

  // ---------- GET ALL NOTIFICATIONS ----------
  Future<List<NotificationModel>> getNotifications(
      String recipientId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('recipient_id', recipientId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => NotificationModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET UNREAD COUNT ----------
  Future<int> getUnreadCount(String recipientId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('recipient_id', recipientId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // ---------- MARK AS READ ----------
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- MARK ALL AS READ ----------
  Future<void> markAllAsRead(String recipientId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', recipientId)
          .eq('is_read', false);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- SUBSCRIBE TO REALTIME NOTIFICATIONS ----------
  StreamController<NotificationModel>? _notificationController;

  Stream<NotificationModel> subscribeToNotifications(
      String recipientId) {
    _notificationController = StreamController<NotificationModel>.broadcast();

    _channel = _client
        .channel('notifications:$recipientId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_id',
            value: recipientId,
          ),
          callback: (payload) {
            final newNotification =
                NotificationModel.fromMap(payload.newRecord);
            _notificationController?.add(newNotification);
          },
        )
        .subscribe();

    return _notificationController!.stream;
  }

  // ---------- UNSUBSCRIBE ----------
  Future<void> unsubscribe() async {
    if (_channel != null) {
      await _client.removeChannel(_channel!);
      _channel = null;
    }
    _notificationController?.close();
    _notificationController = null;
  }

  // ---------- DELETE NOTIFICATION ----------
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- DELETE ALL NOTIFICATIONS ----------
  Future<void> deleteAllNotifications(String recipientId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('recipient_id', recipientId);
    } catch (e) {
      rethrow;
    }
  }
}
