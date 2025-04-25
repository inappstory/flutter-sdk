import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

import 'story_placeholder.dart';

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

    return FutureBuilder(
      future: _prepareVideoController(videoFile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VideoPlayer(controller);
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
    await controller.initialize();
    await controller.setVolume(0.0);
    await controller.setLooping(true);
    await controller.play();
  }
}
