import 'package:raising_india/data/rest_client.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/analytics_response.dart';
import 'package:raising_india/services/service_locator.dart';

class AnalyticsRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  /// Fetch Analytics Data
  /// [filter] values: 'DAILY', 'WEEKLY', 'MONTHLY', 'ALL_TIME'
  Future<AnalyticsResponse> getAnalytics(String filter) async {
    try {
      final response = await _client.getSalesAnalytics(filter);

      if (response.data == null) {
        throw Exception("Analytics data is unavailable.");
      }

      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }
}