// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/demo_feature/data/repositories/demo_repository_impl.dart'
    as _i308;
import '../../features/demo_feature/data/source/demo_api_service.dart' as _i326;
import '../../features/demo_feature/domain/repositories/demo_repository.dart'
    as _i321;
import '../../features/demo_feature/domain/usecases/get_demo_usecase.dart'
    as _i1001;
import '../context/app_context.dart' as _i836;
import '../network/cookies/app_cookie_manager.dart' as _i936;
import '../network/dio/dio_client.dart' as _i479;
import '../storage/token_storage.dart' as _i973;
import '../storage/user_preferences.dart' as _i256;
import 'core_module.dart' as _i154;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    await gh.factoryAsync<_i936.AppCookieManager>(
      () => coreModule.cookieManager,
      preResolve: true,
    );
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i836.AppContext>(() => _i836.AppContext());
    gh.lazySingleton<_i973.TokenStorage>(
      () => coreModule.tokenStorage(gh<_i936.AppCookieManager>()),
    );
    gh.lazySingleton<_i256.UserPreferences>(
      () => coreModule.userPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i479.DioClient>(
      () => coreModule.dioClient(
        gh<_i936.AppCookieManager>(),
        gh<_i973.TokenStorage>(),
        gh<_i256.UserPreferences>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(() => coreModule.dio(gh<_i479.DioClient>()));
    gh.factory<_i326.DemoApiService>(
      () => _i326.DemoApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i321.DemoRepository>(
      () => _i308.DemoRepositoryImpl(gh<_i326.DemoApiService>()),
    );
    gh.lazySingleton<_i1001.GetDemoUseCase>(
      () => _i1001.GetDemoUseCase(gh<_i321.DemoRepository>()),
    );
    return this;
  }
}

class _$CoreModule extends _i154.CoreModule {}
