import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:video_player/video_player.dart';

class StoryWidgetSimpleDecorator extends StatelessWidget
    implements StoryWidget {
  const StoryWidgetSimpleDecorator(this.story, {super.key});

  @override
  final Story story;

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
                  Positioned.fill(child: StoryWidgetSimple(story: story)),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
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

class StoryWidgetSimple extends StatefulWidget {
  const StoryWidgetSimple({super.key, required this.story});

  final Story story;

  @override
  State<StoryWidgetSimple> createState() => _StoryWidgetSimpleState();
}

class _StoryWidgetSimpleState extends State<StoryWidgetSimple> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final videoFile = widget.story.videoFile;
    final imageFile = widget.story.imageFile;

    if (videoFile != null) {
      controller = VideoPlayerController.file(
        videoFile,
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: true,
        ),
      );
      return FutureBuilder(
        future: controller
            ?.initialize()
            .then((value) => controller?.setVolume(0.0))
            .then((value) => controller?.setLooping(true))
            .then((value) => controller?.play()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return VideoPlayer(controller!);
          } else {
            return ColoredBox(color: widget.story.backgroundColor);
          }
        },
      );
    }
    if (imageFile != null) {
      return Image.file(imageFile, fit: BoxFit.cover);
    }

    return ColoredBox(color: story.backgroundColor);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class StoryWidgetSingleReader extends StoryWidgetSimpleDecorator {
  const StoryWidgetSingleReader(super.story, {super.key});

  @override
  void onTap() {
    // TODO: 28.01.2026 !!!!!!!!
    // IASSingleStoryHostApi().showOnce(storyId: '${story.id}');
  }
}
