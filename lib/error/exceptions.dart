// core/error/exceptions.dart

class ServerException implements Exception {
  final String message;

  ServerException({required this.message});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException({required this.message});

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException({required this.message});

  @override
  String toString() => message;
}

class UnAuthorizedException implements Exception {
  final String message;

  UnAuthorizedException({required this.message});

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;

  ValidationException({required this.message});

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => message;
}