import 'package:code_base_riverpod/core/config/environment.dart';
import 'package:code_base_riverpod/core/constants/app_constants.dart';
import 'package:code_base_riverpod/core/network/cookies/app_cookie_manager.dart';
import 'package:code_base_riverpod/core/network/dio/dio_client.dart';
import 'package:code_base_riverpod/core/storage/token_storage.dart';
import 'package:code_base_riverpod/core/storage/user_preferences.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Core module - registers core dependencies
@module
abstract class CoreModule {
  /// Provide DioClient instance
  @preResolve
  Future<AppCookieManager> get cookieManager async {
    return AppCookieManager.create(baseUri: EnvironmentConfig.current.baseUri);
  }

  /// Provide SharedPreferences instance
  @preResolve
  Future<SharedPreferences> get sharedPreferences async {
    return SharedPreferences.getInstance();
  }

  /// Provide strongly-typed preferences wrapper
  @lazySingleton
  UserPreferences userPreferences(SharedPreferences preferences) =>
      UserPreferences(preferences);

  /// Provide TokenStorage instance
  @lazySingleton
  TokenStorage tokenStorage(AppCookieManager cookieManager) =>
      TokenStorage(cookieManager);

  /// Provide DioClient instance
  @lazySingleton
  DioClient dioClient(
    AppCookieManager cookieManager,
    TokenStorage tokenStorage,
    UserPreferences userPreferences,
  ) => DioClient(
    baseUrl: EnvironmentConfig.current.baseUrl,
    cookieManager: cookieManager,
    tokenStorage: tokenStorage,
    userPreferences: userPreferences,
    enableLogging: EnvironmentConfig.current.enableLogging,
    enableCaching: EnvironmentConfig.current.enableCaching,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    sendTimeout: AppConstants.sendTimeout,
  );

  /// Provide Dio instance from DioClient
  @lazySingleton
  Dio dio(DioClient dioClient) => dioClient.dio;

}
