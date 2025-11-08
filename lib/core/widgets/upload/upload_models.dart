import 'dart:typed_data';

/// Describes supported media types that influence previews and icons.
enum UploadMediaType { image, video, file }

/// Lifecycle stage of an upload entry.
enum UploadStage {
  idle,
  queued,
  uploading,
  verifying,
  success,
  failure,
  canceled,
}

/// Compact representation of a picked item ready for upload.
class UploadItem {
  const UploadItem({
    required this.id,
    required this.name,
    required this.sizeInBytes,
    required this.mediaType,
    this.path,
    this.bytes,
    this.thumbnailBytes,
  });

  final String id;
  final String name;
  final int sizeInBytes;
  final UploadMediaType mediaType;
  final String? path;
  final Uint8List? bytes;
  final Uint8List? thumbnailBytes;

  UploadItem copyWith({
    String? id,
    String? name,
    int? sizeInBytes,
    UploadMediaType? mediaType,
    String? path,
    Uint8List? bytes,
    Uint8List? thumbnailBytes,
  }) {
    return UploadItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      mediaType: mediaType ?? this.mediaType,
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
      thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
    );
  }
}

/// Result returned by an upload attempt.
class UploadResult {
  const UploadResult({
    required this.stage,
    this.remoteId,
    this.remoteUrl,
    this.error,
  });

  final UploadStage stage;
  final String? remoteId;
  final String? remoteUrl;
  final Object? error;

  bool get isSuccess => stage == UploadStage.success;
  bool get isFailure => stage == UploadStage.failure;
}

/// Status polled from backend after an upload completes.
class UploadStatus {
  const UploadStatus({required this.stage, this.remoteUrl, this.metadata});

  final UploadStage stage;
  final String? remoteUrl;
  final Map<String, Object?>? metadata;
}

/// Represents the evolving state of an upload item within the controller.
class UploadEntryState {
  const UploadEntryState({
    required this.item,
    this.stage = UploadStage.idle,
    this.progress = 0,
    this.result,
    this.isCheckingStatus = false,
  });

  final UploadItem item;
  final UploadStage stage;
  final double progress;
  final UploadResult? result;
  final bool isCheckingStatus;

  UploadEntryState copyWith({
    UploadItem? item,
    UploadStage? stage,
    double? progress,
    UploadResult? result,
    bool? isCheckingStatus,
  }) {
    return UploadEntryState(
      item: item ?? this.item,
      stage: stage ?? this.stage,
      progress: progress ?? this.progress,
      result: result ?? this.result,
      isCheckingStatus: isCheckingStatus ?? this.isCheckingStatus,
    );
  }
}

UploadMediaType detectMediaType(String fileName) {
  final lower = fileName.toLowerCase();
  if (_imageExtensions.any(lower.endsWith)) {
    return UploadMediaType.image;
  }
  if (_videoExtensions.any(lower.endsWith)) {
    return UploadMediaType.video;
  }
  return UploadMediaType.file;
}

String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  final formatted = value >= 10
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return '$formatted ${units[unitIndex]}';
}

const _imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.heic'];

const _videoExtensions = ['.mp4', '.mov', '.m4v', '.avi', '.webm'];
