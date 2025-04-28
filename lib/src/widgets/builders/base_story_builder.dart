import 'package:flutter/material.dart';

import '../../../inappstory_plugin.dart';

class BaseStoryBuilder extends StatelessWidget implements StoryWidget {
  const BaseStoryBuilder(this.story, {super.key, this.decorator, this.onStoryTap});

  final FeedStoryDecorator? decorator;

  final Function(Story story)? onStoryTap;

  Future<void> onTap(Story story) async => onStoryTap ?? story.showReader();

  @override
  final Story story;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(story),
      child: Stack(
        children: [
          Positioned.fill(
            child: StoryContentWidget(story: story),
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
      ),
    );
  }
}

class StoryWidgetSingleReader extends BaseStoryBuilder {
  const StoryWidgetSingleReader(super.story, {super.key});

  @override
  Future<void> onTap(story) async {
    IASSingleStoryHostApi().showOnce(storyId: '${story.id}');
  }
}
