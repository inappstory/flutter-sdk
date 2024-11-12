# Flutter inappstory_plugin

InAppStory SDK Flutter Plugin

## Installation

Currently under development & not published

Add dependency in your app pubspec.yaml

```yaml
dependencies:
  ...
  inappstory_plugin:
    path: ../inappstory_plugin
  ...
```

## Android Requirements

Make sure you update your Android SDK versions in build.gradle

```
minSdkVersion = 23
compileSdkVersion = 34
targetSdkVersion = 34
```

## Initialize with your api key

```dart
    InappstoryPlugin().initWith('<your api key>', '<user id>', false);
```

## Usage

To use the library, create YourStoryWidget & implement StoryWidget

```dart
class YourStoryWidget extends StatelessWidget implements StoryWidget {
  const YourStoryWidget(this.story, {super.key});
  ...
```

Get story widgets for specific feed

```dart
InappstoryPlugin().getStoriesWidgets('<your feed>', YourStoryWidget.new);
```

Full example

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final initialization = InappstoryPlugin().initWith('<your api key>', '<user id>', false);

  late final futureStoriesWidgets =
      initialization.then((_) => InappstoryPlugin().getStoriesWidgets('<your feed>', StoryWidgetSimpleDecorator.new));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 150,
            child: FutureBuilder(
              future: futureStoriesWidgets,
              builder: (_, snapshot) {
                if (snapshot.hasError) return Text('${snapshot.error}');

                if (snapshot.hasData) {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) => snapshot.requireData.elementAt(index),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: snapshot.requireData.length,
                  );
                }

                return const LinearProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StoryWidgetSimpleDecorator extends StatelessWidget implements StoryWidget {
  const StoryWidgetSimpleDecorator(this.story, {super.key});

  @override
  final Story story;

  Image? get imageNullable {
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
```