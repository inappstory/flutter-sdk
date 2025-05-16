import 'package:flutter/material.dart';

import '../../data/story.dart';
import '../placeholders/story_placeholder.dart';
import '../placeholders/video_story_placeholder.dart';
import 'story_widget.dart';

/// A widget that displays content of a story.
class StoryContentWidget extends StatefulWidget implements StoryWidget {
  const StoryContentWidget({super.key, required this.story});

  @override
  final Story story;

  @override
  State<StoryContentWidget> createState() => _StoryContentWidgetState();
}

class _StoryContentWidgetState extends State<StoryContentWidget> {
  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final videoFile = widget.story.videoFile;

    if (videoFile != null) {
      return VideoStoryPlaceholder(
        videoFile: videoFile,
        storyBackgroundColor: story.backgroundColor,
      );
    }

    final imageFile = widget.story.imageFile;
    if (imageFile != null) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
      );
    }

    return StoryPlaceholder(backgroundColor: story.backgroundColor);
  }
}
