import 'package:flutter/material.dart';

import 'story.dart';

class DefaultStoryWidget extends StatelessWidget {
  const DefaultStoryWidget(this.story, {super.key});

  final Story story;

  Image? get image {
    final imageFile = story.imageFile;

    if (imageFile == null) return null;

    return Image.file(imageFile);
  }

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
              onTap: story.tap,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: image ?? ColoredBox(color: story.backgroundColor),
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
