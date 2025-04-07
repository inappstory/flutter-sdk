import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

import 'story_widget_simple_decorator.dart';

class SimpleFeedExampleWidget extends StatefulWidget {
  const SimpleFeedExampleWidget({super.key});

  @override
  State<SimpleFeedExampleWidget> createState() => _SimpleFeedExampleState();
}

class _SimpleFeedExampleState extends State<SimpleFeedExampleWidget>
    implements CallToActionCallbackFlutterApi, IShowStoryOnceCallbackFlutterApi {
  static const feed = '<your feed id>';

  final inputController = TextEditingController();
  final feedStoriesController = FeedStoriesController();

  final callsToAction = <String>[];

  late var flutterFeedStoriesWidgetsStream = getStoriesWidgets();

  Stream<Iterable<Widget>> getStoriesWidgets() {
    return InAppStoryPlugin().getStoriesWidgets(
      feed: feed,
      storyBuilder: StoryWidgetSimpleDecorator.new,
      storiesController: feedStoriesController,
      favoritesBuilder: (favorites) => CustomGridFeedFavoritesWidget(favorites, onTap: onFeedFavoritesTap),
    );
  }

  void onFeedFavoritesTap() {
    final favorites = InAppStoryPlugin()
        .getFavoritesStoriesWidgets(
          feed: feed,
          storyBuilder: StoryWidgetSimpleDecorator.new,
        )
        .asBroadcastStream();

    showModalBottomSheet(context: context, builder: (_) => FavoritesBottomSheetWidget(favorites));
  }

  @override
  void initState() {
    super.initState();
    CallToActionCallbackFlutterApi.setUp(this);
    IShowStoryOnceCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    CallToActionCallbackFlutterApi.setUp(null);
    IShowStoryOnceCallbackFlutterApi.setUp(null);
    super.dispose();
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
          const Divider(indent: 4),
          ElevatedButton(
            onPressed: () async => await feedStoriesController.fetchFeedStories(),
            child: const Text('Refresh'),
          ),
          const Divider(indent: 4),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(label: Text('Input user id string')),
                    controller: inputController,
                  ),
                ),
                ElevatedButton(onPressed: changeUser, child: const Text('Change userId')),
              ],
            ),
          ),
          const Divider(indent: 4),
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

  void showBanner(String text) {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(text),
        actions: [
          TextButton(
            onPressed: ScaffoldMessenger.of(context).clearMaterialBanners,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void callToAction(SlideDataDto? slideData, String? url, ClickActionDto? clickAction) {
    setState(() {
      final content = 'slideData:$slideData url:$url clickAction:${clickAction?.name}';

      callsToAction.add(content);
    });
  }

  Future<void> changeUser() async {
    await InAppStoryManagerHostApi().changeUser(inputController.text);

    await feedStoriesController.fetchFeedStories();
  }

  int alreadyShownCounter = 0;

  @override
  void alreadyShown() => showBanner('IShowStoryOnceCallback.alreadyShown(${++alreadyShownCounter})');

  int onErrorCounter = 0;

  @override
  void onError() => showBanner('IShowStoryOnceCallback.onError(${++onErrorCounter})');

  int onShowCounter = 0;

  @override
  void onShow() => showBanner('IShowStoryOnceCallback.onShow(${++onShowCounter})');
}

class CustomGridFeedFavoritesWidget extends GridFeedFavoritesWidget {
  CustomGridFeedFavoritesWidget(super.favorites, {required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: super.build(context),
    );
  }
}

class FavoritesBottomSheetWidget extends StatefulWidget {
  const FavoritesBottomSheetWidget(this.favorites, {super.key});

  final Stream<Iterable<Widget>> favorites;

  @override
  State<FavoritesBottomSheetWidget> createState() => _FavoritesBottomSheetWidgetState();
}

class _FavoritesBottomSheetWidgetState extends State<FavoritesBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: SizedBox(
        height: 250,
        child: StreamBuilder(
          stream: widget.favorites,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.requireData.length,
                itemBuilder: (_, index) => snapshot.requireData.elementAt(index),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
              );
            }

            if (snapshot.hasError) return Text('${snapshot.error}');

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
