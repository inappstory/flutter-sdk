import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

import 'keys.dart';

class SimpleFeedExampleWidget extends StatefulWidget {
  const SimpleFeedExampleWidget({super.key});

  @override
  State<SimpleFeedExampleWidget> createState() => _SimpleFeedExampleState();
}

class _SimpleFeedExampleState extends State<SimpleFeedExampleWidget>
    with IASCallbacks, IASCallToActionCallback, IASShowStoryCallback {
  static const feed = Keys.feedId;

  final inputController = TextEditingController();
  final feedStoriesController = FeedStoriesController();
  final feedDecorator = const FeedStoryDecorator(
    storyPadding: 8.0,
    feedPadding: EdgeInsets.only(left: 12.0),
    loaderAspectRatio: 1 / 1,
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    textFontSize: 14.0,
    textPadding: EdgeInsets.all(8.0),
    showBorder: true,
    borderColor: Colors.deepPurple,
    borderWidth: 2.0,
    borderPadding: 4.0,
    favouriteAspectRatio: 7 / 10,
  );

  final callsToAction = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Feed')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeedStoriesWidget(
            feed: feed,
            height: 200,
            controller: feedStoriesController,
            errorBuilder: (context, error) {
              return const Center(child: Text("error"));
            },
            loaderBuilder:
                (context) => DefaultLoaderWidget(decorator: feedDecorator),
            decorator: feedDecorator,
          ),
          const Divider(indent: 4),
          ElevatedButton(
            onPressed:
                () async => await feedStoriesController.fetchFeedStories(),
            child: const Text('Refresh'),
          ),
          const Divider(indent: 4),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      label: Text('Input user id string'),
                    ),
                    controller: inputController,
                  ),
                ),
                ElevatedButton(
                  onPressed: changeUser,
                  child: const Text('Change userId'),
                ),
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
  Future<void> callToAction(
    SlideData? slideData,
    String? url,
    ClickAction? clickAction,
  ) async {
    setState(() {
      final content =
          'slideData:$slideData url:$url clickAction:${clickAction?.name}';

      callsToAction.add(content);
    });
  }

  Future<void> changeUser() async {
    await InAppStoryManager.instance.changeUser(inputController.text);

    await feedStoriesController.fetchFeedStories();
  }

  int alreadyShownCounter = 0;

  @override
  Future<void> alreadyShown() async => showBanner(
    'IShowStoryOnceCallback.alreadyShown(${++alreadyShownCounter})',
  );

  int onErrorCounter = 0;

  @override
  Future<void> onError() async =>
      showBanner('IShowStoryOnceCallback.onError(${++onErrorCounter})');

  int onShowCounter = 0;

  @override
  Future<void> onShow() async =>
      showBanner('IShowStoryOnceCallback.onShow(${++onShowCounter})');

  @override
  Future<void> onCloseStory(SlideData? slideData) async {
    log("closeStory");
  }

  @override
  Future<void> onShowStory(StoryData? storyData) async {
    log("onShowStory");
  }

  @override
  Future<void> onShareStory(SlideData? slideData) async {
    log("onShareStory");
  }

  @override
  Future<void> onDislikeStoryTap(SlideData? slideData, bool isDislike) async {
    log("onDislikeStory $isDislike");
  }

  @override
  Future<void> onLikeStoryTap(SlideData? slideData, bool isLike) async {
    log("onLikeStory $isLike");
  }

  @override
  Future<void> onShowSlide(SlideData? slideData) async {
    log("onShowSlide");
  }

  @override
  Future<void> onFavoriteTap(SlideData? slideData, bool isFavorite) async {
    log("onFavoriteTap $isFavorite");
  }
}
