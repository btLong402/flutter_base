/// Base class for all failures in the domain layer
/// This provides a consistent way to handle errors across the app
abstract class Failure {
  final String message;
  final int? code;
  final dynamic data;

  const Failure({required this.message, this.code, this.data});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Server-related failures (5xx errors)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code, super.data});
}

/// Client-related failures (4xx errors)
class ClientFailure extends Failure {
  const ClientFailure({required super.message, super.code, super.data});
}

/// Network connection failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.data});
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code, super.data});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.data});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code, super.data});
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code, super.data});
}

/// Generic/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code, super.data});
}
