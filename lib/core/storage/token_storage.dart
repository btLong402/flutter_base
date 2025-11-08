

import 'package:code_base_riverpod/core/constants/app_constants.dart';
import 'package:code_base_riverpod/core/network/cookies/app_cookie_manager.dart';

/// Token storage that sources authentication tokens from cookies.
class TokenStorage {
  TokenStorage(this._cookieManager);

  final AppCookieManager _cookieManager;

  /// Get access token from cookies.
  Future<String?> getToken({Uri? uri}) {
    return _cookieManager.getCookieValue(
      AppConstants.accessTokenCookieName,
      uri: uri,
    );
  }

  /// Save access token into cookie jar (useful for mocks or manual overrides).
  Future<bool> saveToken(String token, {Uri? uri}) async {
    await _cookieManager.saveCookie(
      AppConstants.accessTokenCookieName,
      token,
      uri: uri,
    );
    return true;
  }

  /// Get refresh token from cookies.
  Future<String?> getRefreshToken({Uri? uri}) {
    return _cookieManager.getCookieValue(
      AppConstants.refreshTokenCookieName,
      uri: uri,
    );
  }

  /// Save refresh token into cookie jar.
  Future<bool> saveRefreshToken(String token, {Uri? uri}) async {
    await _cookieManager.saveCookie(
      AppConstants.refreshTokenCookieName,
      token,
      uri: uri,
    );
    return true;
  }

  /// Save both tokens in a single operation.
  Future<bool> saveTokens(
    String accessToken,
    String refreshToken, {
    Uri? uri,
  }) async {
    await Future.wait([
      saveToken(accessToken, uri: uri),
      saveRefreshToken(refreshToken, uri: uri),
    ]);
    return true;
  }

  /// Clear authentication tokens from cookies.
  Future<bool> clearTokens({Uri? uri}) async {
    await Future.wait([
      _cookieManager.deleteCookie(AppConstants.accessTokenCookieName, uri: uri),
      _cookieManager.deleteCookie(
        AppConstants.refreshTokenCookieName,
        uri: uri,
      ),
    ]);
    return true;
  }

  /// Check if user is authenticated.
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
