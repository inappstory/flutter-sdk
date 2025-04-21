import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/story_from_pigeon_dto.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef StoryWidgetBuilder = Widget Function(Story story, FeedStoryDecorator? decorator);

class BaseStoryWidget extends StatefulWidget implements StoryWidget {
  const BaseStoryWidget(this.story, this.storyWidgetBuilder, {super.key, this.storyDecorator, this.onTap});

  final StoryWidgetBuilder storyWidgetBuilder;

  final FeedStoryDecorator? storyDecorator;

  final Function(Story story)? onTap;

  @override
  final StoryFromPigeonDto story;

  @override
  State<BaseStoryWidget> createState() => _BaseStoryWidgetState();
}

class _BaseStoryWidgetState extends State<BaseStoryWidget> {
  StoryFromPigeonDto get story => widget.story;

  StoryWidgetBuilder get storyWidgetBuilder => widget.storyWidgetBuilder;

  FeedStoryDecorator? get storyDecorator => widget.storyDecorator;

  void _onVisibilityChanged(VisibilityInfo info) {
    story.wasViewed();
  }

  void _onTap() => widget.onTap ?? story.showReader();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(story),
      onVisibilityChanged: _onVisibilityChanged,
      child: StreamBuilder(
        stream: story.updates,
        builder: (_, __) {
          return ClipRRect(
            borderRadius: storyDecorator?.borderRadius ?? const BorderRadius.all(Radius.circular(10)),
            child: AspectRatio(
              aspectRatio: story.aspectRatio,
              child: GestureDetector(
                onTap: _onTap,
                child: storyWidgetBuilder(story, storyDecorator),
              ),
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
