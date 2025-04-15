# Flutter inappstory_plugin

InAppStory SDK Flutter Plugin

## Installation

Currently under development & not published

Add dependency in your app `pubspec.yaml`

```
dependencies:
  ...
  inappstory_plugin: ^0.1.0-rc.1
  ...
```

## Android Requirements

1. Make sure you update your Android SDK versions in `app/build.gradle`

```
minSdkVersion = 23
compileSdkVersion = 34
targetSdkVersion = 34
```

2. Init Android SDK in your `Application` class in Android project

> **IMPORTANT:**
> Without this, the library will not work

```kotlin
// Kotlin
package com.example.yourapp

import android.app.Application
import com.inappstory.inappstory_plugin.InappstoryPlugin

class ExampleApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // init SKD
        InappstoryPlugin.initSDK(this)
    }
}
```

```java
// Java
package com.example.yourapp;

import android.app.Application;

import com.inappstory.inappstory_plugin.InappstoryPlugin;


class ExampleApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        InappstoryPlugin.initSDK(this);
    }
}
```

3. Add manifestPlaceholders to your `app/build.gradle` file

```
android {
    ...
    defaultConfig {
        ...
        manifestPlaceholders['applicationName'] = '<name of your custom application class>'
    }
}
```

## Initialize with your api key

Should await returned future first before use of other API

``` dart
    await InappstoryPlugin().initWith('<your api key>', '<user id>', false);
    
    // ... any other calls to API
```

## Usage

To use the library, create `YourStoryWidget` & implement `StoryWidget`

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

You can use FeedStoriesController to force reload the feed stories

```
final feedStoriesController = FeedStoriesController();
  
InAppStoryPlugin().getStoriesWidgets(
  feedController: feedStoriesController,
...
);   
// reload feed
await feedStoriesController.fetchFeedStories();
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
    feed: '<your feed>',
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
      feed: '<your feed>',
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

## Story Reader Background

```
AppearanceManagerHostApi().setReaderBackgroundColor(Colors.green.value)
```

## Story Reader Corner Radius

```
AppearanceManagerHostApi().setReaderCornerRadius(16); // int
```

# InAppStoryManagerHostApi

## Methods

`void setPlaceholders(Map<String, String> newPlaceholders);` - change Placeholders

`void setTags(List<String> tags);` - replacing all tags

`void changeUser(String userId)` - replace the user in the application

`void closeReaders();` - closing any story reader that showing

##

# User Settings

## Change user id

It may be necessary to replace the user in the application. For example - during registration or
re-authorization.

To get this - you can use the `InAppStoryManagerHostApi().changeUser(<your new user>)` method.

UserId can't be longer than 255 characters.

Get stories for new user `InAppStoryPlugin().getStoriesWidgets(...)` or
`await FeedStoriesController().fetchFeedStories()`.

## SingleStoryAPI

To show single story in reader by id

```
IASSingleStoryHostApi().show(storyId: story.id);
```

To show single story in reader by id if wasn't show already for current user

```
IASSingleStoryHostApi().showOnce(storyId: story.id);
```

To listen callbacks of result show()/showOnce() implement IShowStoryOnceCallbackFlutterApi and setUp
your listener

```dart
class _WidgetState extends State<T> implements IShowStoryOnceCallbackFlutterApi {
  @override
  void initState() {
    super.initState();
    IShowStoryOnceCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    IShowStoryOnceCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  void alreadyShown() => print('IShowStoryOnceCallback.alreadyShown()');

  @override
  void onError() => print('IShowStoryOnceCallback.onError()');

  @override
  void onShow() => print('IShowStoryOnceCallback.onShow()');
}
```

## Call To Action

add/remove listener for CTA

1. Implement interface CallToActionCallbackFlutterApi
2. Setup this listener

```dart
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
}
```

## Onboardings

The library supports work with onboarding stories.

```dart
void onOnboardingsTap() {
  IASOnboardingsHostApi().show(limit: 10);
}
```

To listen success callback

```dart
class _MyAppState extends State<MyApp> implements OnboardingLoadCallbackFlutterApi {
  @override
  void initState() {
    super.initState();
    OnboardingLoadCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    OnboardingLoadCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  void onboardingLoad(int count, String feed) {
    print('$runtimeType.onboardingLoad($count, $feed)');
  }

  @override
  void onboardingLoadError(String feed, String? reason) {
    print('$runtimeType.onboardingLoad($feed, $reason)');
  }
}  
```

## Games

The library supports run games.

```dart
// To run game
void openGame() async {
  await IASGamesHostApi().open('<game id>');
}
// To close game
void closeGame() async {
  await IASGamesHostApi().closeGame();
}
```

If you want to preload games by yourself (f.e. in case if your app doesn't use any stories), you can call next method:

```dart
void preloadGames() async {
  await IASGamesHostApi().preloadGames();
}
```

To listen callbacks from game you can implement `GameCallbackFlutterApi` and setup your listener

```dart
class _MyAppState extends State<MyApp> implements GameCallbackFlutterApi {
  @override
  void initState() {
    super.initState();
    GameReaderCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    GameReaderCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  void startGame(ContentDataDto? gameData) {
    print('startGame ${gameData?.contentType.toString()}');
  }

  @override
  void closeGame(ContentDataDto? gameData) {
    print('closeGame');
  }

  @override
  void eventGame(ContentDataDto? gameData, String? id, String? eventName, Map<String?, Object?>? payload) {
    print('eventGame');
  }

  @override
  void finishGame(ContentDataDto? gameData, Map<String?, Object?>? result) {
    print('finishGame');
  }

  @override
  void gameError(ContentDataDto? gameData, String? message) {
    print('gameError');
  }
}
```

