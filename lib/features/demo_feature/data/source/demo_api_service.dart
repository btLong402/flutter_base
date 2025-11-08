import 'package:code_base_riverpod/core/network/response/api_response.dart';
import 'package:code_base_riverpod/features/demo_feature/domain/models/demo_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'demo_api_service.g.dart';

@injectable
@RestApi()
abstract class DemoApiService {
  @factoryMethod
  factory DemoApiService(Dio dio) = _DemoApiService;

  @GET('/')
  Future<ApiResponse<DemoModel>> getPosts();
}
