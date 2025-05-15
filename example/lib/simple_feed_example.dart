import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

class SimpleFeedExampleWidget extends StatefulWidget {
  const SimpleFeedExampleWidget({super.key});

  @override
  State<SimpleFeedExampleWidget> createState() => _SimpleFeedExampleState();
}

class _SimpleFeedExampleState extends State<SimpleFeedExampleWidget>
    with IASCallbacks
    implements CallToActionCallbackFlutterApi, IShowStoryCallbackFlutterApi {
  static const feed = '<your feed id>';

  final inputController = TextEditingController();
  final feedStoriesController = FeedStoriesController();
  final feedDecorator = const FeedStoryDecorator(
    storyPadding: 12.0,
    feedPadding: EdgeInsets.only(top: 4.0),
    loaderAspectRatio: 1 / 1,
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    textFontSize: 14.0,
    textPadding: EdgeInsets.all(8.0),
  );

  final callsToAction = <String>[];

  void onFeedFavoritesTap() {
    //showModalBottomSheet(context: context, builder: (_) => FavoritesBottomSheetWidget());
  }

  @override
  void initState() {
    super.initState();
    CallToActionCallbackFlutterApi.setUp(this);
    IShowStoryCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    CallToActionCallbackFlutterApi.setUp(null);
    IShowStoryCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Feed'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeedStoriesWidget(
            feed: feed,
            controller: feedStoriesController,
            loaderBuilder: (context) =>
                DefaultLoaderWidget(decorator: feedDecorator),
            decorator: feedDecorator,
          ),
          const Divider(indent: 4),
          ElevatedButton(
            onPressed: () async =>
                await feedStoriesController.fetchFeedStories(),
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
                        label: Text('Input user id string')),
                    controller: inputController,
                  ),
                ),
                ElevatedButton(
                    onPressed: changeUser, child: const Text('Change userId')),
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
      SlideDataDto? slideData, String? url, ClickActionDto? clickAction) {
    setState(() {
      final content =
          'slideData:$slideData url:$url clickAction:${clickAction?.name}';

      callsToAction.add(content);
    });
  }

  Future<void> changeUser() async {
    await InAppStoryManagerHostApi().changeUser(inputController.text);

    await feedStoriesController.fetchFeedStories();
  }

  int alreadyShownCounter = 0;

  @override
  void alreadyShown() => showBanner(
      'IShowStoryOnceCallback.alreadyShown(${++alreadyShownCounter})');

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
    print("closeStory");
  }

  @override
  void onShowStory(StoryDataDto? storyData) {
    print("onShowStory");
  }

  @override
  void onShareStory(SlideDataDto? slideData) {
    print("onShareStory");
  }

  @override
  void onDislikeStoryTap(SlideDataDto? slideData, bool isDislike) {
    print("onDislikeStory $isDislike");
  }

  @override
  void onLikeStoryTap(SlideDataDto? slideData, bool isLike) {
    print("onLikeStory $isLike");
  }

  @override
  void onShowSlide(SlideDataDto? slideData) {
    print("onShowSlide");
  }

  @override
  void onFavoriteTap(SlideDataDto? slideData, bool isFavorite) {
    print("onFavoriteTap $isFavorite");
  }
}

class CustomGridFeedFavoritesWidget extends GridFeedFavoritesWidget {
  CustomGridFeedFavoritesWidget(super.favorites,
      {required this.onTap, super.key});

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
  State<FavoritesBottomSheetWidget> createState() =>
      _FavoritesBottomSheetWidgetState();
}

class _FavoritesBottomSheetWidgetState
    extends State<FavoritesBottomSheetWidget> {
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
                itemBuilder: (_, index) =>
                    snapshot.requireData.elementAt(index),
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

class FeedExample extends StatelessWidget {
  FeedExample({super.key});

  final feedController = FeedStoriesController();

  @override
  Widget build(BuildContext context) {
    return FeedStoriesWidget(
      feed: "<your_feed_id>",
      controller: feedController,
      errorBuilder: (context, error) {
        return Column(
          children: [
            Text("Error loading feed: $error"),
            ElevatedButton(
              onPressed: () => feedController.fetchFeedStories(),
              child: const Text("Retry"),
            ),
          ],
        );
      },
    );
  }
}
