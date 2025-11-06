# InAppStory

<!-- markdownlint-disable MD013 -->
<p align="center">
    <a href="https://inappstory.com/">
        <img height="210" src="https://docs.inappstory.com/images/Logo_Star.svg" width="210"/>    
    </a>
</p>

A Flutter plugin to use [InAppStory SDK](https://inappstory.com/). Supports Android and iOS
platforms.

Currently under development & not published

The full documentation for InAppStory SDK can be found
on [docs.inappstory.com](https://docs.inappstory.com/sdk-guides/flutter/how-to-get-started.html).

## Installation

Add dependency in your app `pubspec.yaml`

```yaml
dependencies:
  inappstory_plugin: ^0.5.2
```

## Full example

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final initialization = InAppStoryPlugin().initWith('<your api key>', '<user id>');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: initialization,
        builder: (context, initializationSnapshot) {
          if (initializationSnapshot.connectionState ==
              ConnectionState.done) {
            if (initializationSnapshot.hasError) {
              return const Text('SDK was not initialized');
            } else {
              return FeedStoriesWidget(
                feed: feed,
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
```