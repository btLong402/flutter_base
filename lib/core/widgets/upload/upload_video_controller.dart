import 'package:video_player/video_player.dart';

import 'upload_models.dart';
import 'upload_video_controller_stub.dart'
    if (dart.library.io) 'upload_video_controller_io.dart';

Future<VideoPlayerController?> createVideoController(UploadItem item) {
  return createControllerImpl(item);
}
