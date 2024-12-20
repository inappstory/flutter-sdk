import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

class StoryWidgetSimpleDecorator extends StatelessWidget implements StoryWidget {
  const StoryWidgetSimpleDecorator(this.story, {super.key});

  @override
  final Story story;

  Image? get imageNullable {
    final imageFile = story.imageFile;

    if (imageFile == null) return null;

    return Image.file(imageFile);
  }

  void onTap() => story.showReader();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: story.updates,
      builder: (_, __) {
        return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: AspectRatio(
            aspectRatio: story.aspectRatio,
            child: GestureDetector(
              onTap: onTap,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageNullable ?? ColoredBox(color: story.backgroundColor),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
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
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        story.title,
                        style: TextStyle(color: story.titleColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class StoryWidgetSingleReader extends StoryWidgetSimpleDecorator {
  const StoryWidgetSingleReader(super.story, {super.key});

  @override
  void onTap() {
    IASSingleStoryHostApi().showOnce(storyId: story.id);
  }
}
