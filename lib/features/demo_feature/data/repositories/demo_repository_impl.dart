import 'package:code_base_riverpod/core/base/base_repository.dart';
import 'package:code_base_riverpod/core/base/base_usecase.dart';
import 'package:code_base_riverpod/core/error/exceptions.dart';
import 'package:code_base_riverpod/features/demo_feature/data/source/demo_api_service.dart';
import 'package:code_base_riverpod/features/demo_feature/domain/models/demo_model.dart';
import 'package:code_base_riverpod/features/demo_feature/domain/repositories/demo_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: DemoRepository)
class DemoRepositoryImpl extends BaseRepository implements DemoRepository {
  DemoRepositoryImpl(this._apiService);

  final DemoApiService _apiService;

  @override
  FutureResult<DemoModel> getDemo() {
    return execute(() async {
      final response = await _apiService.getPosts();
      final data = response.data;

      if (response.success == false) {
        throw ServerException(
          message: response.message ?? 'Request failed',
          code: response.statusCode,
          data: response.errors,
        );
      }

      if (data == null) {
        throw ServerException(message: 'Empty response data');
      }

      return data;
    });
  }
}
