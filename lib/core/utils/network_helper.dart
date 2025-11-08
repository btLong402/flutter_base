import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity helper
class NetworkHelper {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device is connected to internet
  static Future<bool> isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet);
  }

  /// Stream of connectivity changes
  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);
    });
  }

  /// Get current connectivity status
  static Future<ConnectivityResult> getCurrentConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return results.firstOrNull ?? ConnectivityResult.none;
  }
}
