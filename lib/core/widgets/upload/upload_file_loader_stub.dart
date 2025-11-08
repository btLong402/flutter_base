import 'dart:typed_data';

import 'upload_models.dart';

Future<Uint8List?> loadBytesImpl(UploadItem item) async {
  return item.bytes;
}
