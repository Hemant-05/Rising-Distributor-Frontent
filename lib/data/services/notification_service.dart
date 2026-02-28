import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/notification_repo.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/notification.dart';

class NotificationService extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Useful for showing a Red Dot on the Bell Icon
  int get unreadCount => _notifications.where((n) => !n.read).length;

  // 1. Fetch Admin Notifications
  Future<void> fetchAdminNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _repo.getAdminNotifications();
    } catch (e) {
      print("Notification Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Mark as Read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].read = true;
      notifyListeners();
    }
    try {
      await _repo.markAsRead(id);
    } catch (e) {
      print("Failed to mark read on server: $e");
      // Optional: Revert change if server fails
    }
  }

  // 3. Send Broadcast (Admin only)
  Future<String?> sendBroadcast(String title, String body) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.sendBroadcast(title, body);
      return null; // Success
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to send notification.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Add Real-time Notification (For FCM Foreground Handler)
  void addLiveNotification(NotificationModel notif) {
    _notifications.insert(0, notif);
    notifyListeners();
  }

  Future<void> fetchUserNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Calls the new repository method we just made
      _notifications = await _repo.getUserNotifications(userId);
    } catch (e) {
      print("User Notification Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}