import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/notification_repo.dart';
import 'package:raising_india/error/exceptions.dart';

class NotificationService extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();

  Future<String?> sendBroadcast(String title, String body) async {
    try {
      await _repo.sendBroadcast(title, body);
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to send notification.";
    }
  }
}