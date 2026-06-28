import 'package:dio/dio.dart';
import 'package:raising_india/error/exceptions.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class HealthRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  Future<Map<String, dynamic>> getApiHealth() {
    return _readHealthResponse(_client.getHealth);
  }

  Future<Map<String, dynamic>> getDatabaseHealth() {
    return _readHealthResponse(_client.getDatabaseHealth);
  }

  Future<Map<String, dynamic>> _readHealthResponse(
    Future<dynamic> Function() request,
  ) async {
    try {
      return _toMap(await request());
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData != null) {
        return _toMap(responseData);
      }
      throw handleError(e);
    } catch (e) {
      throw handleError(e);
    }
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {'status': 'UNKNOWN', 'response': value?.toString()};
  }
}
