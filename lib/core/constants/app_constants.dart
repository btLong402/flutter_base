/// Application-wide constants
class AppConstants {
  AppConstants._();

  // API Configuration
  static const String baseUrl =
      'https://api.example.com'; // TODO: Replace with your API URL

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String userKey = 'user_data';

  // Cookie Keys
  static const String accessTokenCookieName = 'access_token';
  static const String refreshTokenCookieName = 'refresh_token';
  static const String cookiePath = '/';

  // Cache Configuration
  static const Duration cacheMaxAge = Duration(hours: 1);
  static const int cacheMaxStale = 7; // days

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Configuration
  static const int maxImageSizeKB = 2048; // 2MB
  static const double imageQuality = 0.8;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Debounce/Throttle
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration buttonThrottle = Duration(milliseconds: 300);

  // Retry Policy
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Feature Flags (can be moved to remote config)
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
}

/// API Endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  static const String uploadAvatar = '/user/avatar';

  // Dashboard (example)
  static const String dashboardData = '/dashboard';
  static const String dashboardStats = '/dashboard/stats';
}

/// HTTP Headers
class HttpHeaders {
  HttpHeaders._();

  static const String authorization = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String acceptLanguage = 'Accept-Language';
  static const String cacheControl = 'Cache-Control';
}
