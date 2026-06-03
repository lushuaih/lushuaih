import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/firebase_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _notifications = await _firebase.getNotifications(userId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '加载通知失败';
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _firebase.markNotificationRead(notificationId);
    
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _unreadCount = (_unreadCount - 1).clamp(0, double.maxFinite.toInt());
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    for (final notification in _notifications) {
      if (!notification.isRead) {
        await _firebase.markNotificationRead(notification.id);
      }
    }
    
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    String? content,
    String? postId,
    String? actorId,
    String? actorName,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      type: type,
      title: title,
      content: content,
      postId: postId,
      actorId: actorId,
      actorName: actorName,
      createdAt: DateTime.now(),
    );

    await _firebase.createNotification(notification);
    
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
