import 'package:flutter/material.dart';

import '../../story.dart';
import '../story_widget.dart';
import 'story_placeholder.dart';
import 'video_story_placeholder.dart';

class SimpleStoryPlaceholderWidget extends StatefulWidget implements StoryWidget {
  const SimpleStoryPlaceholderWidget({super.key, required this.story});

  @override
  final Story story;

  @override
  State<SimpleStoryPlaceholderWidget> createState() => _SimpleStoryPlaceholderWidgetState();
}

class _SimpleStoryPlaceholderWidgetState extends State<SimpleStoryPlaceholderWidget> {
  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final videoFile = widget.story.videoFile;

    if (videoFile != null) {
      return VideoStoryPlaceholder(videoFile: videoFile, storyBackgroundColor: story.backgroundColor);
    }

    final imageFile = widget.story.imageFile;
    if (imageFile != null) {
      return Image.file(imageFile);
    }

    return StoryPlaceholder(backgroundColor: story.backgroundColor);
  }
}
