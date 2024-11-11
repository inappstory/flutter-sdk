import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/story_from_pigeon_dto.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef StoryWidgetBuilder = StoryWidget Function(Story);

class BaseStoryWidget extends StatefulWidget implements StoryWidget {
  const BaseStoryWidget(this.story, this.storyWidgetBuilder, {super.key});

  final StoryWidgetBuilder storyWidgetBuilder;

  @override
  final StoryFromPigeonDto story;

  @override
  State<BaseStoryWidget> createState() => _BaseStoryWidgetState();
}

class _BaseStoryWidgetState extends State<BaseStoryWidget> {
  StoryFromPigeonDto get story => widget.story;

  StoryWidgetBuilder get storyWidgetBuilder => widget.storyWidgetBuilder;

  void onVisibilityChanged(VisibilityInfo info) {
    story.wasViewed();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(story),
      onVisibilityChanged: onVisibilityChanged,
      child: storyWidgetBuilder(story),
    );
  }

  @override
  void dispose() {
    story.controller.close();
    super.dispose();
  }
}
