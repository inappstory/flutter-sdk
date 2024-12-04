import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

import 'story_widget_simple_decorator.dart';

class SimpleFeedExampleWidget extends StatefulWidget {
  const SimpleFeedExampleWidget({super.key});

  @override
  State<SimpleFeedExampleWidget> createState() => _SimpleFeedExampleState();
}

class _SimpleFeedExampleState extends State<SimpleFeedExampleWidget> implements CallToActionCallbackFlutterApi {
  final flutterFeedStoriesWidgetsStream = InAppStoryPlugin().getStoriesWidgets(
    feed: 'flutter',
    storyBuilder: StoryWidgetSimpleDecorator.new,
    favoritesBuilder: GridFeedFavoritesWidget.new,
  );

  @override
  void initState() {
    super.initState();
    CallToActionCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    CallToActionCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  final callsToAction = <String>[];

  @override
  void callToAction(SlideDataDto? slideData, String? url, ClickActionDto? clickAction) {
    setState(() {
      final content = 'slideData:$slideData url:$url clickAction:${clickAction?.name}';

      callsToAction.add(content);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpleFeedExample'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 100,
            child: StreamBuilder(
              stream: flutterFeedStoriesWidgetsStream,
              builder: (_, storiesSnapshot) {
                if (storiesSnapshot.hasData) {
                  return ListView.separated(
                    itemCount: storiesSnapshot.requireData.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) => storiesSnapshot.requireData.elementAt(index),
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                  );
                }

                if (storiesSnapshot.hasError) {
                  return Text(
                    '${storiesSnapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }
                return const LinearProgressIndicator();
              },
            ),
          ),
          const Divider(),
          const Text('Calls To Actions'),
          Expanded(
            child: ListView.builder(
              itemCount: callsToAction.length,
              itemBuilder: (_, index) => Text(callsToAction[index]),
            ),
          ),
        ],
      ),
    );
  }
}
