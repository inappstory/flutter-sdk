# InAppStory

<!-- markdownlint-disable MD013 -->
<p align="center">
    <a href="https://www.inappstory.com/">
        <img height="210" src="https://docs.inappstory.com/images/Logo_Star.svg" width="210"/>    
    </a>
</p>

A Flutter plugin to use [InAppStory SDK](https://www.inappstory.com/). Supports Android and iOS platforms.

Currently under development & not published

The full documentation for InAppStory SDK can be found
on [docs.inappstory.com](https://docs.inappstory.com/sdk-guides/flutter/how-to-get-started.html).

## Full example

```dart
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
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
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