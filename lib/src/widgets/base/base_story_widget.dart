import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../inappstory_plugin.dart';
import '../../data/story_from_pigeon_dto.dart';
import '../builders/builders.dart';

class BaseStoryWidget extends StatefulWidget implements StoryWidget {
  const BaseStoryWidget(this.story, this.storyWidgetBuilder, {super.key, required this.storyDecorator});

  final StoryWidgetBuilder storyWidgetBuilder;

  final FeedStoryDecorator storyDecorator;

  @override
  final StoryFromPigeonDto story;

  @override
  State<BaseStoryWidget> createState() => _BaseStoryWidgetState();
}

class _BaseStoryWidgetState extends State<BaseStoryWidget> {
  StoryFromPigeonDto get story => widget.story;

  StoryWidgetBuilder get storyWidgetBuilder => widget.storyWidgetBuilder;

  FeedStoryDecorator get storyDecorator => widget.storyDecorator;

  void _onVisibilityChanged(VisibilityInfo info) {
    story.wasViewed();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(story),
      onVisibilityChanged: _onVisibilityChanged,
      child: StreamBuilder(
        stream: story.updates,
        builder: (_, __) {
          return ClipRRect(
            borderRadius: storyDecorator.borderRadius,
            child: AspectRatio(
              aspectRatio: story.aspectRatio,
              child: storyWidgetBuilder(story, storyDecorator),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    story.controller.close();
    super.dispose();
  }
}
