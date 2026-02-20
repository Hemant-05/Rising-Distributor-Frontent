import 'package:dio/dio.dart';

class AppError implements Exception {
  final String message;
  final String? prefix;

  AppError(this.message, [this.prefix]);

  @override
  String toString() => "$prefix$message";
}
// 1. No Internet
class NetworkException extends AppError {
  NetworkException([String message = "No Internet Connection"])
      : super(message, "Network Error: ");
}

// 2. 401 Unauthorized (Wrong Password / Token Expired)
class AuthenticationException extends AppError {
  AuthenticationException([String message = "Authentication Failed"])
      : super(message, "");
}

// 3. 400 Bad Request (Validation Errors, "Email already exists")
class ValidationException extends AppError {
  ValidationException([String message = "Invalid Request"])
      : super(message, "");
}

// 4. 500 Server Error (Backend crashed)
class ServerException extends AppError {
  ServerException([String message = "Server Error"])
      : super(message, "");
}

// 5. Unknown / General Error
class UnknownException extends AppError {
  UnknownException([String message = "An unexpected error occurred"])
      : super(message, "");
}

// 6. 404 Not Found
class NotFoundException extends AppError {
  NotFoundException([String message = "Not Found"]) : super(message, "");
}

// 7. 403 Forbidden
class UnAuthorizedException extends AppError {
  UnAuthorizedException([String message = "Unauthorized"])
      : super(message, "");
}

mixin RepoErrorHandler {
  Exception handleError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final serverMessage = _extractServerMessage(error.response?.data);

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return NetworkException("Server took too long to respond.");
      } else if (error.type == DioExceptionType.connectionError) {
        return NetworkException("No Internet Connection.");
      } else if (statusCode == 401 || statusCode == 403) {
        return AuthenticationException(serverMessage ?? "Session expired. Please login again.");
      } else if (statusCode == 400 || statusCode == 409) {
        return ValidationException(serverMessage ?? "Invalid request.");
      } else if (statusCode == 404) {
        return ValidationException("Resource not found.");
      } else if (statusCode != null && statusCode >= 500) {
        return ServerException("Internal Server Error.");
      }
      return UnknownException(serverMessage ?? "Something went wrong.");
    }
    return UnknownException(error.toString());
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'];
      if (data['error'] != null) return data['error'];
    }
    return null;
  }
}