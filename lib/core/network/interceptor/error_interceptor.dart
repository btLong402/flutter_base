import 'package:code_base_riverpod/core/utils/logger.dart';
import 'package:dio/dio.dart';


/// Error interceptor to handle errors globally
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log the error
    AppLogger.logApiError(
      err.requestOptions.uri.toString(),
      err.response?.statusCode,
      error: err.message,
    );

    // Map to custom exception (for potential future use)
    // final exception = ExceptionHandler.handleDioException(err);

    // You can add custom logic here, e.g.:
    // - Show global error messages
    // - Track errors in analytics
    // - Redirect to login on 401

    // Pass the error to the next handler
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log successful responses
    AppLogger.logResponse(
      response.requestOptions.uri.toString(),
      response.statusCode ?? 0,
    );

    handler.next(response);
  }
}
