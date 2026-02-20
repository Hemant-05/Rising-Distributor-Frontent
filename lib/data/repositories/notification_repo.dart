import 'package:raising_india/error/exceptions.dart';
import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class NotificationRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  Future<void> sendBroadcast(String title, String body) async {
    try {
      await _client.sendBroadcast(title, body);
    } catch (e) {
      throw handleError(e);
    }
  }
}