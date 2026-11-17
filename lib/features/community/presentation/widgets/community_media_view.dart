import 'package:flutter/material.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/video_controller_factory.dart';
import 'package:roadlink/features/community/data/community_catalog.dart';
import 'package:video_player/video_player.dart';

/// Renders an image, video, or reel attached to a [CommunityPost].
class CommunityMediaView extends StatelessWidget {
  final CommunityMediaAttachment media;

  const CommunityMediaView({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (media.type == CommunityMediaType.image) {
      return AspectRatio(
        aspectRatio: 16 / 8.5,
        child: media.bytes != null
            ? Image.memory(
                media.bytes!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: c.surfaceRaised),
              )
            : media.assetPath != null
                ? Image.asset(
                    media.assetPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: c.surfaceRaised),
                  )
                : Container(color: c.surfaceRaised),
      );
    }

    // Video or Reel
    if (media.videoPath != null && media.videoPath!.isNotEmpty) {
      return _CommunityVideoPlayer(
        videoPath: media.videoPath!,
        isReel: media.type == CommunityMediaType.reel,
        fileName: media.fileName,
      );
    }

    // Bundled sample reel preview (thumbnail + REEL badge)
    final isReel = media.type == CommunityMediaType.reel;
    return AspectRatio(
      aspectRatio: isReel ? 16 / 9 : 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (media.assetPath != null)
            Image.asset(
              media.assetPath!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: AppPalette.navy900),
            )
          else
            Container(color: AppPalette.navy900),
          Container(
            color: AppPalette.navy900.withValues(alpha: 0.25),
          ),
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppPalette.navy900.withValues(alpha: 0.78),
                shape: BoxShape.circle,
                border: Border.all(color: AppPalette.neutral0, width: 1.5),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 30,
                color: AppPalette.neutral0,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: _MediaTypeBadge(isReel: isReel),
          ),
        ],
      ),
    );
  }
}

class _MediaTypeBadge extends StatelessWidget {
  final bool isReel;

  const _MediaTypeBadge({required this.isReel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: AppPalette.blue500,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isReel ? Icons.movie_creation_outlined : Icons.videocam_outlined,
            size: 13,
            color: AppPalette.neutral0,
          ),
          const SizedBox(width: 4),
          Text(
            isReel ? 'REEL' : 'VIDEO',
            style: AppTypography.caption.copyWith(
              color: AppPalette.neutral0,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityVideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool isReel;
  final String fileName;

  const _CommunityVideoPlayer({
    required this.videoPath,
    required this.isReel,
    required this.fileName,
  });

  @override
  State<_CommunityVideoPlayer> createState() => _CommunityVideoPlayerState();
}

class _CommunityVideoPlayerState extends State<_CommunityVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      final controller = createVideoController(widget.videoPath);
      _controller = controller;
      await controller.initialize();
      await controller.setLooping(widget.isReel);
      if (!mounted) return;
      setState(() => _initialized = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !_initialized) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null || !_initialized) return;
    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.isReel ? 4 / 5 : 16 / 9;

    if (_hasError) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: AppPalette.navy900,
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.video_file_outlined,
                size: 36,
                color: AppPalette.blue500,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                widget.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppPalette.neutral0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller;
    if (!_initialized || controller == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: AppPalette.navy900,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: AppPalette.blue500),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.isReel ? 420 : 320),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio > 0
            ? controller.value.aspectRatio
            : aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: _togglePlay,
              child: VideoPlayer(controller),
            ),
            if (!controller.value.isPlaying)
              IgnorePointer(
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppPalette.navy900.withValues(alpha: 0.78),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.neutral0, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 32,
                      color: AppPalette.neutral0,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 10,
              left: 10,
              child: _MediaTypeBadge(isReel: widget.isReel),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: _toggleMute,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppPalette.navy900.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    size: 16,
                    color: AppPalette.neutral0,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppPalette.blue500,
                  bufferedColor: AppPalette.neutral400,
                  backgroundColor: AppPalette.navy800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

