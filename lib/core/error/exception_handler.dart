import 'dart:io';
import 'package:dio/dio.dart';
import 'exceptions.dart';

/// Exception handler to map Dio errors to custom exceptions
class ExceptionHandler {
  /// Map DioException to custom AppException
  static AppException handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Request timeout. Please try again.',
          code: error.response?.statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response!);

      case DioExceptionType.cancel:
        return AppException(
          message: 'Request cancelled',
          code: error.response?.statusCode,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException(
            message: 'No internet connection',
            code: error.response?.statusCode,
          );
        }
        return NetworkException(
          message: 'Network error occurred',
          code: error.response?.statusCode,
          data: error.response?.data,
        );

      default:
        return AppException(
          message: 'Unexpected error occurred',
          code: error.response?.statusCode,
          data: error.response?.data,
        );
    }
  }

  /// Handle HTTP status codes
  static AppException _handleStatusCode(Response response) {
    final statusCode = response.statusCode ?? 0;
    final message = _extractErrorMessage(response.data);

    if (statusCode >= 500) {
      return ServerException(
        message: message ?? 'Server error occurred',
        code: statusCode,
        data: response.data,
      );
    } else if (statusCode == 401) {
      return UnauthorizedException(
        message: message ?? 'Unauthorized access',
        code: statusCode,
        data: response.data,
      );
    } else if (statusCode == 403) {
      return AuthException(
        message: message ?? 'Access forbidden',
        code: statusCode,
        data: response.data,
      );
    } else if (statusCode >= 400) {
      return ClientException(
        message: message ?? 'Client error occurred',
        code: statusCode,
        data: response.data,
      );
    }

    return AppException(
      message: message ?? 'Unknown error occurred',
      code: statusCode,
      data: response.data,
    );
  }

  /// Extract error message from response data
  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Try common error message keys
      return data['message'] ??
          data['error'] ??
          data['errorMessage'] ??
          data['msg'];
    }

    if (data is String) {
      return data;
    }

    return null;
  }

  /// Handle general exceptions
  static AppException handleException(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException) {
      return NetworkException(message: 'No internet connection');
    }

    return AppException(message: error.toString());
  }
}
