import 'package:dio/dio.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/services/service_locator.dart';

abstract class BaseRepository {
  /// Standard error handler to convert DioExceptions into UI messages.
  /// This replaces the manual logic in your old DioClient.
/*  String handleErroro(dynamic error) {
    if (error is DioException) {
      // Access the backend's custom error message if available.
      final backendMessage = error.response?.data is Map
          ? error.response?.data['message']
          : null;
      final ex = mapDioException(error);
      // our mapping returns Exception subclasses that have `message` field
      if (ex is ServerException) return ex.message;
      if (ex is AuthenticationException) return ex.message;
      if (ex is ValidationException) return ex.message;
      if (ex is NetworkException) return ex.message;
      return 'An unexpected error occurred \n ${error.message}';
    }
    return error.toString();
  }*/

  String handleError(dynamic error) {
    if (error is DioException) {
      final backendMessage = error.response?.data is Map
          ? error.response?.data['message']
          : null;

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection timed out. Please try again.";
        case DioExceptionType.badResponse:
          return backendMessage ?? "Server error: ${error.response?.statusCode}";
        case DioExceptionType.connectionError:
          return "No internet connection.";
        default:
          return backendMessage ?? "An unexpected error occurred.";
      }
    }
    return error.toString();
  }
}