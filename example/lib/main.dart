import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _inappstoryPlugin = InappstoryPlugin();

  final defaultFeedStoriesStream = StoriesStream.feed('default');

  @override
  void initState() {
    super.initState();
    _inappstoryPlugin.initWith('test-key', 'testUserId', true, false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 24),
              SizedBox(
                height: 100,
                child: StreamBuilder(
                  stream: defaultFeedStoriesStream,
                  builder: (_, snap) {
                    if (snap.hasData) {
                      return ListView.separated(
                        itemCount: snap.requireData.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index) {
                          final story = snap.requireData.elementAt(index);
                          return DefaultStoryAPIDataWidget(story);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(width: 16);
                        },
                      );
                    }

                    if (snap.hasError) {
                      return Text(
                        '${snap.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }

                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class StoryAPIDataWidget implements StatefulWidget {
  StoryAPIData get storyAPIData;
}

class DefaultStoryAPIDataWidget extends StatefulWidget implements StoryAPIDataWidget {
  const DefaultStoryAPIDataWidget(this.storyAPIData, {super.key});

  @override
  final StoryAPIData storyAPIData;

  @override
  State<DefaultStoryAPIDataWidget> createState() => _DefaultStoryAPIDataWidgetState();
}

class _DefaultStoryAPIDataWidgetState extends State<DefaultStoryAPIDataWidget> {
  get api => IASStoryListHostApi();

  StoryAPIData get storyAPIData => widget.storyAPIData;

  void onTap() => api.openStoryReader(storyAPIData.id);

  @override
  Widget build(BuildContext context) {
    final imageFilePath = storyAPIData.imageFilePath;
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: AspectRatio(
        aspectRatio: storyAPIData.aspectRatio,
        child: GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: imageFilePath != null
                    ? Image.network(
                        imageFilePath,
                        fit: BoxFit.cover,
                      )
                    : ColoredBox(color: colorFromString(storyAPIData.backgroundColor)),
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
                    storyAPIData.title,
                    style: TextStyle(color: colorFromString(storyAPIData.titleColor)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color colorFromString(String string) {
  return Color(
    int.parse(
      string.replaceAll(RegExp('^#'), '0xff'),
    ),
  );
}
