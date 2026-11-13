import 'dart:io';
import 'package:video_player/video_player.dart';

/// Creates a [VideoPlayerController] for Mobile/Desktop platforms.
VideoPlayerController createVideoController(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return VideoPlayerController.networkUrl(Uri.parse(path));
  }
  return VideoPlayerController.file(File(path));
}

