import 'dart:io';
import 'dart:typed_data';

import 'upload_models.dart';

Future<Uint8List?> loadBytesImpl(UploadItem item) async {
  if (item.bytes != null) {
    return item.bytes;
  }
  final path = item.path;
  if (path == null) {
    return null;
  }
  final file = File(path);
  if (!await file.exists()) {
    return null;
  }
  return file.readAsBytes();
}
