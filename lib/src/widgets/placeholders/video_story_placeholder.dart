import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'story_placeholder.dart';

/// A widget that displays a video story placeholder.
class VideoStoryPlaceholder extends StatefulWidget {
  const VideoStoryPlaceholder({
    super.key,
    required this.videoFile,
    required this.storyBackgroundColor,
  });

  final File videoFile;
  final Color storyBackgroundColor;

  @override
  State<VideoStoryPlaceholder> createState() => _VideoStoryPlaceholderState();
}

class _VideoStoryPlaceholderState extends State<VideoStoryPlaceholder> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.videoFile);
  }

  @override
  Widget build(BuildContext context) {
    final videoFile = widget.videoFile;

    if (controller.value.isInitialized) {
      return VisibilityDetector(
        key: ObjectKey(videoFile),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction == 0) {
            if (mounted) {
              controller.pause();
            }
          } else {
            controller.play();
          }
        },
        child: VideoPlayer(controller),
      );
    }
    return FutureBuilder(
      future: _prepareVideoController(videoFile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VisibilityDetector(
            key: ObjectKey(videoFile),
            onVisibilityChanged: (VisibilityInfo info) {
              if (info.visibleFraction == 0) {
                if (mounted) {
                  controller.pause();
                }
              } else {
                controller.play();
              }
            },
            child: VideoPlayer(controller),
          );
        } else {
          return StoryPlaceholder(backgroundColor: widget.storyBackgroundColor);
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _prepareVideoController(File videoFile) async {
    if (controller.value.isInitialized) {
      return;
    }
    await controller.initialize();
    await controller.setVolume(0.0);
    await controller.setLooping(true);
    await controller.play();
  }
}
