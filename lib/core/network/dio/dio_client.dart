import 'package:code_base_riverpod/core/constants/app_constants.dart';
import 'package:code_base_riverpod/core/network/cookies/app_cookie_manager.dart';
import 'package:code_base_riverpod/core/network/interceptor/error_interceptor.dart';
import 'package:code_base_riverpod/core/storage/token_storage.dart';
import 'package:code_base_riverpod/core/storage/user_preferences.dart';
import 'package:code_base_riverpod/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Dio client factory
class DioClient {
  late final Dio _dio;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
  final bool enableCaching;
  final AppCookieManager cookieManager;
  final TokenStorage tokenStorage;
  final UserPreferences userPreferences;

  DioClient({
    required this.baseUrl,
    required this.cookieManager,
    required this.tokenStorage,
    required this.userPreferences,
    this.connectTimeout = AppConstants.connectTimeout,
    this.receiveTimeout = AppConstants.receiveTimeout,
    this.sendTimeout = AppConstants.sendTimeout,
    this.enableLogging = true,
    this.enableCaching = true,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _setupInterceptors();
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Setup interceptors
  void _setupInterceptors() {
    // Cookie interceptor must be first to ensure cookies are synced
    _dio.interceptors.add(cookieManager.dioInterceptor);

    // Auth interceptor adds authorization headers based on cookies
    // _dio.interceptors.add(
    //   AuthInterceptor(
    //     tokenStorage: tokenStorage,
    //     cookieManager: cookieManager,
    //     userPreferences: userPreferences,
    //   ),
    // );

    // Cache interceptor
    if (enableCaching) {
      _dio.interceptors.add(_getCacheInterceptor());
    }

    // Logger interceptor (should be after cache to log actual requests)
    if (enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Error interceptor (must be last to catch all errors)
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// Get cache interceptor with Hive store
  DioCacheInterceptor _getCacheInterceptor() {
    final cacheOptions = CacheOptions(
      store: HiveCacheStore(null), // Will be initialized in main
      policy: CachePolicy.request,
      hitCacheOnErrorCodes: [401, 403],
      maxStale: const Duration(days: AppConstants.cacheMaxStale),
      priority: CachePriority.normal,
      cipher: null,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      allowPostMethod: false,
    );

    return DioCacheInterceptor(options: cacheOptions);
  }

  /// Add custom interceptor
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Remove interceptor
  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }

  /// Clear all interceptors
  void clearInterceptors() {
    _dio.interceptors.clear();
  }

  /// Build a Retrofit service using the configured Dio instance.
  T createService<T>(T Function(Dio dio) builder) {
    return builder(_dio);
  }
}
