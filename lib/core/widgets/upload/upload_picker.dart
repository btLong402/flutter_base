import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'upload_models.dart';

/// Configuration describing what kind of sources are allowed.
enum UploadPickerType { media, images, videos, files }

class UploadPicker {
  const UploadPicker({
    this.allowMultiple = true,
    this.type = UploadPickerType.media,
  });

  final bool allowMultiple;
  final UploadPickerType type;

  Future<List<UploadItem>> pick() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: _mapType(type),
      allowCompression: false,
      withData: true,
      withReadStream: !kIsWeb,
    );
    if (result == null) {
      return const [];
    }

    return result.files.map(_mapFile).whereType<UploadItem>().toList();
  }

  UploadItem? _mapFile(PlatformFile file) {
    final bytes = file.bytes;
    final path = file.path;
    if (bytes == null && path == null) {
      return null;
    }
    final name = file.name;
    final size = file.size;
    final mediaType = detectMediaType(name);
    final id =
        path ?? 'mem-${name.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    return UploadItem(
      id: id,
      name: name,
      sizeInBytes: size,
      mediaType: mediaType,
      path: path,
      bytes: bytes,
      thumbnailBytes: file.bytes,
    );
  }

  FileType _mapType(UploadPickerType type) {
    switch (type) {
      case UploadPickerType.media:
        return FileType.media;
      case UploadPickerType.images:
        return FileType.image;
      case UploadPickerType.videos:
        return FileType.video;
      case UploadPickerType.files:
        return FileType.any;
    }
  }
}
