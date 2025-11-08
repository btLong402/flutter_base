/// Base exception class for all custom exceptions
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic data;

  AppException({required this.message, this.code, this.data});

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

/// Server exceptions (5xx)
class ServerException extends AppException {
  ServerException({required super.message, super.code, super.data});
}

/// Client exceptions (4xx)
class ClientException extends AppException {
  ClientException({required super.message, super.code, super.data});
}

/// Network connection exceptions
class NetworkException extends AppException {
  NetworkException({required super.message, super.code, super.data});
}

/// Cache exceptions
class CacheException extends AppException {
  CacheException({required super.message, super.code, super.data});
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException({required super.message, super.code, super.data});
}

/// Timeout exceptions
class TimeoutException extends AppException {
  TimeoutException({required super.message, super.code, super.data});
}

/// Unauthorized exceptions
class UnauthorizedException extends AppException {
  UnauthorizedException({required super.message, super.code, super.data});
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException({required super.message, super.code, super.data});
}

/// Permission exceptions
class PermissionException extends AppException {
  PermissionException({required super.message, super.code, super.data});
}
