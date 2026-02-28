import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/notification.dart';
import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class NotificationRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  // 1. Send Broadcast
  Future<void> sendBroadcast(String title, String body) async {
    try {
      await _client.sendBroadcast(title, body);
    } catch (e) {
      throw handleError(e);
    }
  }

  // 2. Fetch History
  Future<List<NotificationModel>> getAdminNotifications() async {
    try {
      final response = await _client.getAdminNotifications();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  // 3. Mark Read
  Future<void> markAsRead(String id) async {
    try {
      await _client.markNotificationRead(id);
    } catch (e) {
      throw handleError(e);
    }
  }

  // ✅ ADD THIS: Fetch User Notifications
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      print('----------------- $userId');
      final response = await _client.getUserNotifications(userId);
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }
}