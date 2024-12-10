# Flutter inappstory_plugin

InAppStory SDK Flutter Plugin

## Installation

Currently under development & not published

Add dependency in your app pubspec.yaml

```
dependencies:
  ...
  inappstory_plugin: ^0.0.6
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

```
    InappstoryPlugin().initWith('<your api key>', '<user id>', false);
```

## Usage

To use the library, create YourStoryWidget & implement StoryWidget

```
class YourStoryWidget extends StatelessWidget implements StoryWidget {
  const YourStoryWidget(this.story, {super.key});
  ...
```

Get story widgets for specific feed

```
InAppStoryPlugin().getStoriesWidgets(
  feed: '<your feed>',
  storyBuilder: <function returns Widget for Story>,
);
```

Get story widgets for specific feed with Favorites item

```
InAppStoryPlugin().getStoriesWidgets(
  feed: '<your feed>',
  storyBuilder: <function returns Widget for Story>,
  favoritesBuilder: <function returns Widget for in feed Favorites>,
);
```

Full example

```
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final initialization = InappstoryPlugin().initWith('<your api key>', '<user id>', false);

  final flutterFeedStoriesWidgetsStream = InAppStoryPlugin().getStoriesWidgets(
    feed: 'flutter',
    storyBuilder: StoryWidgetSimpleDecorator.new,
    favoritesBuilder: GridFeedFavoritesWidget.new, // Can be null
  );

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
            child: StreamBuilder(
              stream: flutterFeedStoriesWidgetsStream,
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

## Get Favorites Stories

```
final favorites = InAppStoryPlugin().getFavoritesStoriesWidgets(
      feed: 'flutter',
      storyBuilder: StoryWidgetSimpleDecorator.new,
    ).asBroadcastStream();
```


# AppearanceManager

## Story Reader appearance

Show/hide buttons for:

- likes/dislikes
- favorite
- share

```
AppearanceManagerHostApi().setHasLike(true);
AppearanceManagerHostApi().setHasFavorites(true);
AppearanceManagerHostApi().setHasShare(true);

```

## Story Reader close button position

- Position.topLeft
- Position.topRight
- Position.bottomLeft
- Position.bottomRight


```
AppearanceManagerHostApi().setClosePosition(position)
```

## Story Reader Timer Gradient

set state enable/disable
```
AppearanceManagerHostApi().setTimerGradientEnable(true)
```

get state
```
final Future<bool> timerGradientEnabledFuture= AppearanceManagerHostApi().getTimerGradientEnable();
```

set Gradient with Colors & locations

```
const gradient = LinearGradient(colors: [Colors.purple, Colors.amber], stops: [0.1, 0.3]);

AppearanceManagerHostApi().setTimerGradient(
                        colors: gradient.colors.map((it) => it.value).toList(),
                        locations: gradient.stops ?? [],
                      );
```

## Call To Action

add/remove listener for CTA

1. Implement interface CallToActionCallbackFlutterApi
2. Setup this listener

```
class _SimpleFeedExampleState extends State<SimpleFeedExampleWidget> implements CallToActionCallbackFlutterApi {
  @override
  void initState() {
    super.initState();
    CallToActionCallbackFlutterApi.setUp(this); // add listener
  }

  @override
  void dispose() {
    CallToActionCallbackFlutterApi.setUp(null); // remove listener
    super.dispose();
  }

  final callsToAction = <String>[];

  @override
  void callToAction(SlideDataDto? slideData, String? url, ClickActionDto? clickAction) {
    // Do anything related
  }
``` 