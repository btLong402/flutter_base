import 'dart:typed_data';

import 'upload_models.dart';
import 'upload_file_loader_stub.dart'
    if (dart.library.io) 'upload_file_loader_io.dart';

Future<Uint8List?> loadUploadBytes(UploadItem item) => loadBytesImpl(item);
