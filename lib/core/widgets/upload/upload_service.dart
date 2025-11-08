import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'upload_models.dart';

typedef UploadProgressCallback = void Function(double progress);

/// Contract describing how the widget interacts with backend infrastructure.
abstract class UploadService {
  Future<UploadResult> upload({
    required UploadItem item,
    required UploadProgressCallback onProgress,
    CancelableOperation? cancelToken,
  });

  Future<UploadStatus?> checkStatus({required UploadResult result});
}

/// Lightweight wrapper enabling cancellation of in-flight uploads.
class CancelableOperation {
  CancelableOperation();

  final _isCanceled = ValueNotifier<bool>(false);

  bool get isCanceled => _isCanceled.value;

  void cancel() {
    if (!_isCanceled.value) {
      _isCanceled.value = true;
    }
  }

  void listen(ValueChanged<bool> listener) {
    _isCanceled.addListener(() => listener(_isCanceled.value));
  }
}

/// Basic mock useful for demos and testing.
class MockUploadService implements UploadService {
  MockUploadService({
    this.failRate = 0.15,
    this.minDelay = const Duration(milliseconds: 400),
    this.maxDelay = const Duration(milliseconds: 1600),
    this.statusDelay = const Duration(milliseconds: 600),
  });

  final double failRate;
  final Duration minDelay;
  final Duration maxDelay;
  final Duration statusDelay;

  @override
  Future<UploadResult> upload({
    required UploadItem item,
    required UploadProgressCallback onProgress,
    CancelableOperation? cancelToken,
  }) async {
    final random = _random;
    final total =
        minDelay.inMilliseconds +
        random.nextInt(maxDelay.inMilliseconds - minDelay.inMilliseconds + 1);
    const chunk = Duration(milliseconds: 120);
    var elapsed = 0;
    cancelToken?.listen((canceled) {
      if (canceled) {
        throw const UploadCanceledException();
      }
    });

    while (elapsed < total) {
      await Future<void>.delayed(chunk);
      elapsed += chunk.inMilliseconds;
      final value = (elapsed / total).clamp(0, 0.95).toDouble();
      onProgress(value);
    }

    onProgress(1.0);
    final failed = random.nextDouble() < failRate;
    if (failed) {
      return UploadResult(stage: UploadStage.failure, error: 'Network error');
    }
    return UploadResult(
      stage: UploadStage.success,
      remoteId: 'upload-${DateTime.now().millisecondsSinceEpoch}',
      remoteUrl: 'https://files.example.com/${item.name}',
    );
  }

  @override
  Future<UploadStatus?> checkStatus({required UploadResult result}) async {
    if (result.remoteId == null) {
      return null;
    }
    await Future<void>.delayed(statusDelay);
    return UploadStatus(
      stage: UploadStage.success,
      remoteUrl: result.remoteUrl,
    );
  }
}

final _random = Random();

class UploadCanceledException implements Exception {
  const UploadCanceledException();

  @override
  String toString() => 'Upload canceled';
}
