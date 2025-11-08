import 'package:code_base_riverpod/core/base/base_usecase.dart';
import 'package:code_base_riverpod/features/demo_feature/domain/models/demo_model.dart';

abstract class DemoRepository {
  FutureResult<DemoModel> getDemo();
}
