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
    with IASCallbacks, IASCallToActionCallback
    implements IShowStoryCallbackFlutterApi {
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
  void initState() {
    super.initState();
    IShowStoryCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    IShowStoryCallbackFlutterApi.setUp(null);
    super.dispose();
  }

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
  void callToAction(
    SlideDataDto? slideData,
    String? url,
    ClickActionDto? clickAction,
  ) {
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
  void alreadyShown() => showBanner(
    'IShowStoryOnceCallback.alreadyShown(${++alreadyShownCounter})',
  );

  int onErrorCounter = 0;

  @override
  void onError() =>
      showBanner('IShowStoryOnceCallback.onError(${++onErrorCounter})');

  int onShowCounter = 0;

  @override
  void onShow() =>
      showBanner('IShowStoryOnceCallback.onShow(${++onShowCounter})');

  @override
  void onCloseStory(SlideDataDto? slideData) {
    log("closeStory");
  }

  @override
  void onShowStory(StoryDataDto? storyData) {
    log("onShowStory");
  }

  @override
  void onShareStory(SlideDataDto? slideData) {
    log("onShareStory");
  }

  @override
  void onDislikeStoryTap(SlideDataDto? slideData, bool isDislike) {
    log("onDislikeStory $isDislike");
  }

  @override
  void onLikeStoryTap(SlideDataDto? slideData, bool isLike) {
    log("onLikeStory $isLike");
  }

  @override
  void onShowSlide(SlideDataDto? slideData) {
    log("onShowSlide");
  }

  @override
  void onFavoriteTap(SlideDataDto? slideData, bool isFavorite) {
    log("onFavoriteTap $isFavorite");
  }
}
