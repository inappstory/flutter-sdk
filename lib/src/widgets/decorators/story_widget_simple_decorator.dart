import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

import '../placeholders/simple_story_placeholder.dart';

class StorySimpleDecorator extends StatelessWidget implements StoryWidget {
  const StorySimpleDecorator(this.story, {super.key, this.decorator});

  final FeedStoryDecorator? decorator;

  @override
  final Story story;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SimpleStoryPlaceholderWidget(story: story),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: decorator?.foregroundDecoration ??
                const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                    ],
                  ),
                ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: decorator?.textPadding ?? const EdgeInsets.all(8.0),
            child: Text(
              story.title,
              style: TextStyle(
                color: story.titleColor,
                fontSize: decorator?.textFontSize ?? 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StoryWidgetSingleReader extends StorySimpleDecorator {
  const StoryWidgetSingleReader(super.story, {super.key});

  void onTap() {
    IASSingleStoryHostApi().showOnce(storyId: '${story.id}');
  }
}
