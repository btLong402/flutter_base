import 'package:code_base_riverpod/core/error/failures.dart';
import 'package:dartz/dartz.dart';

typedef FutureResult<T> = Future<Either<Failure, T>>;
typedef StreamResult<T> = Stream<Either<Failure, T>>;

abstract class UseCase<T, Params> {
  FutureResult<T> call(Params params);
}

abstract class UseCaseNoParams<T> {
  FutureResult<T> call();
}

abstract class StreamUseCase<T, Params> {
  StreamResult<T> call(Params params);
}

abstract class StreamUseCaseNoParams<T> {
  StreamResult<T> call();
}

class NoParams {
  const NoParams();
}
