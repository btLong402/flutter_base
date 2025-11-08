import 'package:code_base_riverpod/core/base/base_usecase.dart';
import 'package:code_base_riverpod/features/demo_feature/domain/models/demo_model.dart';
import 'package:code_base_riverpod/features/demo_feature/domain/repositories/demo_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetDemoUseCase extends UseCaseNoParams<DemoModel> {
  GetDemoUseCase(this._repository);

  final DemoRepository _repository;

  @override
  FutureResult<DemoModel> call() {
    return _repository.getDemo();
  }
}
