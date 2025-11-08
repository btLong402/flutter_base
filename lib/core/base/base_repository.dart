import 'package:dartz/dartz.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';

/// Base repository with common error handling logic
/// All repository implementations can extend this to get consistent error handling
abstract class BaseRepository {
  /// Execute an async operation with automatic error handling
  /// Converts exceptions to Failures using the Either pattern
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// Future<Either<Failure, User>> getUser(String id) async {
  ///   return execute(() async {
  ///     final userModel = await apiService.getUser(id);
  ///     return userModel.toEntity();
  ///   });
  /// }
  /// ```
  Future<Either<Failure, T>> execute<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on ClientException catch (e) {
      return Left(ClientFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// Execute a synchronous operation with automatic error handling
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// Either<Failure, bool> isLoggedIn() {
  ///   return executeSync(() {
  ///     return tokenStorage.hasToken();
  ///   });
  /// }
  /// ```
  Either<Failure, T> executeSync<T>(T Function() operation) {
    try {
      final result = operation();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on ClientException catch (e) {
      return Left(ClientFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// Execute with custom error mapping
  /// Use this when you need specific error handling logic
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// Future<Either<Failure, Data>> getData() async {
  ///   return executeWithMapping(
  ///     () async => await apiService.getData(),
  ///     onError: (error) {
  ///       if (error is TimeoutException) {
  ///         return NetworkFailure(message: 'Request timeout');
  ///       }
  ///       return UnknownFailure(message: error.toString());
  ///     },
  ///   );
  /// }
  /// ```
  Future<Either<Failure, T>> executeWithMapping<T>(
    Future<T> Function() operation, {
    required Failure Function(Object error) onError,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      return Left(onError(e));
    }
  }
}
