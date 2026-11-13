import 'package:video_player/video_player.dart';

/// Creates a [VideoPlayerController] for Web (`blob:` or `https://` URLs).
VideoPlayerController createVideoController(String path) {
  return VideoPlayerController.networkUrl(Uri.parse(path));
}

