import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Extension methods for Either to make it easier to work with
extension EitherX<L, R> on Either<L, R> {
  /// Get the right value or null
  R? get rightOrNull {
    return fold((l) => null, (r) => r);
  }

  /// Get the left value or null
  L? get leftOrNull {
    return fold((l) => l, (r) => null);
  }

  /// Execute action only on right value
  Either<L, R> onRight(void Function(R value) action) {
    return fold((l) => Left(l), (r) {
      action(r);
      return Right(r);
    });
  }

  /// Execute action only on left value
  Either<L, R> onLeft(void Function(L value) action) {
    return fold((l) {
      action(l);
      return Left(l);
    }, (r) => Right(r));
  }

  /// Transform right value
  Either<L, T> mapRight<T>(T Function(R value) transform) {
    return fold((l) => Left(l), (r) => Right(transform(r)));
  }

  /// Transform left value
  Either<T, R> mapLeft<T>(T Function(L value) transform) {
    return fold((l) => Left(transform(l)), (r) => Right(r));
  }

  /// Flat map for chaining Either operations
  Either<L, T> flatMap<T>(Either<L, T> Function(R value) transform) {
    return fold((l) => Left(l), (r) => transform(r));
  }
}

/// Extension methods specifically for Either<Failure, T>
extension FailureEitherX<R> on Either<Failure, R> {
  /// Get the value or throw the failure as an exception
  R getOrThrow() {
    return fold(
      (failure) => throw Exception(failure.message),
      (value) => value,
    );
  }

  /// Get the value or return a default value (eager evaluation)
  R getOrElse(R Function() defaultValue) {
    return fold((_) => defaultValue(), (value) => value);
  }

  /// Get the value or compute a default value with failure context
  R getOrElseCompute(R Function(Failure failure) defaultValue) {
    return fold((failure) => defaultValue(failure), (value) => value);
  }

  /// Get the value or return a default value directly (no function)
  R getOrDefault(R defaultValue) {
    return fold((_) => defaultValue, (value) => value);
  }

  /// Get the failure message or null
  String? get failureMessage {
    return fold((failure) => failure.message, (_) => null);
  }

  /// Check if it's a specific failure type
  bool isFailureType<T extends Failure>() {
    return fold((failure) => failure is T, (_) => false);
  }

  /// Execute action only on success
  Either<Failure, R> onSuccess(void Function(R value) action) {
    return onRight(action);
  }

  /// Execute action only on failure
  Either<Failure, R> onFailure(void Function(Failure failure) action) {
    return onLeft(action);
  }

  /// Convert to Future (useful for async operations)
  Future<R> toFuture() async {
    return getOrThrow();
  }

  /// Convert to Future with default value
  Future<R> toFutureOr(R defaultValue) async {
    return getOrDefault(defaultValue);
  }
}

/// Utility functions for working with Either
class EitherUtils {
  /// Combine multiple Either results
  /// Returns Left if any result is Left, otherwise returns Right with all values
  static Either<Failure, List<T>> combine<T>(List<Either<Failure, T>> results) {
    final values = <T>[];

    for (final result in results) {
      final value = result.fold((failure) => failure, (value) => value);

      if (value is Failure) {
        return Left(value);
      }

      values.add(value as T);
    }

    return Right(values);
  }

  /// Combine two Either results
  static Either<Failure, (T1, T2)> combine2<T1, T2>(
    Either<Failure, T1> either1,
    Either<Failure, T2> either2,
  ) {
    return either1.flatMap((value1) {
      return either2.mapRight((value2) => (value1, value2));
    });
  }

  /// Combine three Either results
  static Either<Failure, (T1, T2, T3)> combine3<T1, T2, T3>(
    Either<Failure, T1> either1,
    Either<Failure, T2> either2,
    Either<Failure, T3> either3,
  ) {
    return combine2(either1, either2).flatMap((tuple) {
      return either3.mapRight((value3) => (tuple.$1, tuple.$2, value3));
    });
  }

  /// Execute multiple async operations and combine results
  static Future<Either<Failure, List<T>>> sequence<T>(
    List<Future<Either<Failure, T>>> futures,
  ) async {
    final results = await Future.wait(futures);
    return combine(results);
  }

  /// Traverse a list and execute operation on each item
  static Future<Either<Failure, List<R>>> traverse<T, R>(
    List<T> items,
    Future<Either<Failure, R>> Function(T item) operation,
  ) async {
    final results = <R>[];

    for (final item in items) {
      final result = await operation(item);

      if (result.isLeft()) {
        return Left(result.leftOrNull as Failure);
      }

      results.add(result.rightOrNull as R);
    }

    return Right(results);
  }
}

/// Example usage:
///
/// ```dart
/// // Using extensions
/// final result = await loginUseCase(params);
///
/// // Get value or null
/// final user = result.rightOrNull;
///
/// // Get error message
/// final error = result.failureMessage;
///
/// // Execute action on success
/// result.onSuccess((authResult) {
///   print('Logged in as ${authResult.user.name}');
/// });
///
/// // Chain operations
/// final userName = result
///   .mapRight((authResult) => authResult.user)
///   .mapRight((user) => user.name)
///   .getOrElse('Unknown');
///
/// // Combine multiple results
/// final user1Future = getUserUseCase(userId1);
/// final user2Future = getUserUseCase(userId2);
///
/// final combined = await EitherUtils.sequence([
///   user1Future,
///   user2Future,
/// ]);
///
/// combined.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (users) => print('Got ${users.length} users'),
/// );
/// ```
