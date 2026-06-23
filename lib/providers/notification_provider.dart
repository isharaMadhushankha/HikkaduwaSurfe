import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<NotificationModel>? _realtimeSub;

  // ---------- GETTERS ----------
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  // ---------- LOAD NOTIFICATIONS ----------
  Future<void> loadNotifications(String recipientId) async {
    _setLoading(true);
    _clearError();
    try {
      _notifications =
          await _notificationService.getNotifications(recipientId);
      _unreadCount =
          await _notificationService.getUnreadCount(recipientId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- SUBSCRIBE TO REALTIME ----------
  void subscribeToRealtime(String recipientId) {
    _realtimeSub?.cancel();

    final stream =
        _notificationService.subscribeToNotifications(recipientId);

    _realtimeSub = stream.listen((notification) {
      _notifications.insert(0, notification);
      _unreadCount++;
      notifyListeners();
    });
  }

  // ---------- MARK AS READ ----------
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        // Replace with read version
        final old = _notifications[index];
        _notifications[index] = NotificationModel(
          id: old.id,
          recipientId: old.recipientId,
          type: old.type,
          title: old.title,
          message: old.message,
          isRead: true,
          bookingId: old.bookingId,
          createdAt: old.createdAt,
        );
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ---------- MARK ALL AS READ ----------
  Future<void> markAllAsRead(String recipientId) async {
    try {
      await _notificationService.markAllAsRead(recipientId);
      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          recipientId: n.recipientId,
          type: n.type,
          title: n.title,
          message: n.message,
          isRead: true,
          bookingId: n.bookingId,
          createdAt: n.createdAt,
        );
      }).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ---------- DELETE NOTIFICATION ----------
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      final wasUnread =
          _notifications.any((n) => n.id == notificationId && !n.isRead);
      _notifications.removeWhere((n) => n.id == notificationId);
      if (wasUnread) {
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ---------- DELETE ALL ----------
  Future<void> deleteAllNotifications(String recipientId) async {
    try {
      await _notificationService.deleteAllNotifications(recipientId);
      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ---------- UNSUBSCRIBE ----------
  void unsubscribe() {
    _realtimeSub?.cancel();
    _realtimeSub = null;
    _notificationService.unsubscribe();
  }

  // ---------- CLEAR ALL ----------
  void clearAll() {
    unsubscribe();
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  // ---------- HELPERS ----------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}
