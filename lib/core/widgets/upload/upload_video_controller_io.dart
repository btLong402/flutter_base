import 'dart:io';

import 'package:video_player/video_player.dart';

import 'upload_models.dart';

Future<VideoPlayerController?> createControllerImpl(UploadItem item) async {
  final path = item.path;
  if (path == null) {
    return null;
  }
  final file = File(path);
  if (!await file.exists()) {
    return null;
  }
  return VideoPlayerController.file(file);
}
