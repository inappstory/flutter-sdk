import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/feed_stories_controller.dart';
import 'builders/base_story_builder.dart';
import 'builders/builders.dart';
import 'decorators/default_feed_favorites_widget.dart';
import 'decorators/feed_decorator.dart';
import 'streams/feed_stories_stream.dart';

/// A widget that displays a feed of stories in a horizontal list.
///
/// This widget fetches and displays stories from a specified feed, with
/// customizable builders for loading, error, story, and favorites widgets.
class FeedStoriesWidget extends StatefulWidget {
  /// Creates a [FeedStoriesWidget].
  ///
  /// [feed] is the identifier of the feed to fetch stories from.
  /// [controller] is an optional controller to manage the feed.
  /// [height] specifies the height of the widget. Defaults to 120.0.
  /// [loaderBuilder] is an optional builder for the loading widget.
  /// [errorBuilder] is an optional builder for the error widget.
  /// [decorator] is an optional decorator for customizing the appearance.
  /// [storyBuilder] is an optional builder for individual story widgets.
  /// [favoritesBuilder] is an optional builder for the favorites widget.
  const FeedStoriesWidget({
    super.key,
    required this.feed,
    this.controller,
    this.height = 120.0,
    this.loaderBuilder,
    this.errorBuilder,
    this.decorator,
    this.storyBuilder,
    this.favoritesBuilder,
    this.storiesLoaded,
  });

  /// The identifier of the feed to fetch stories from.
  final String feed;

  /// The height of the widget.
  final double height;

  /// An optional controller to manage the feed.
  final FeedStoriesController? controller;

  /// An optional decorator for customizing the appearance of the widget.
  final FeedStoryDecorator? decorator;

  /// An optional builder for the loading widget.
  final FeedLoaderWidgetBuilder? loaderBuilder;

  /// An optional builder for the error widget.
  final FeedErrorWidgetBuilder? errorBuilder;

  /// An optional builder for individual story widgets.
  final StoryWidgetBuilder? storyBuilder;

  /// An optional builder for the favorites widget.
  final FeedFavoritesWidgetBuilder? favoritesBuilder;

  final Function(int size, String feed)? storiesLoaded;

  @override
  State<FeedStoriesWidget> createState() => FeedStoriesWidgetState();
}

/// The state for the [FeedStoriesWidget].
///
/// Manages the fetching and display of stories, as well as the customization
/// of loading, error, story, and favorites widgets.
class FeedStoriesWidgetState extends State<FeedStoriesWidget> {
  /// A stream of widgets representing the stories in the feed.
  late final _feedStoriesWidgetsStream = _getStoriesWidgets();

  /// The controller for managing the feed.
  late FeedStoriesController _feedController;

  /// The decorator for customizing the appearance of the widget.
  late FeedStoryDecorator? feedDecorator;

  /// The builder for individual story widgets.
  late StoryWidgetBuilder _storyBuilder;

  /// The builder for the loading widget.
  FeedLoaderWidgetBuilder? loaderBuilder;

  /// The builder for the error widget.
  late FeedErrorWidgetBuilder? errorBuilder;

  /// The builder for the favorites widget.
  late FeedFavoritesWidgetBuilder _favoritesBuilder;

  final scrollController = ScrollController();
  late final observerController =
      ListObserverController(controller: scrollController);

  @override
  initState() {
    super.initState();
    _feedController = widget.controller ?? FeedStoriesController();
    errorBuilder = widget.errorBuilder;
    feedDecorator = widget.decorator ?? FeedStoryDecorator();
    loaderBuilder = widget.loaderBuilder;
    _storyBuilder = widget.storyBuilder ??
        (story, decorator) => BaseStoryBuilder(story, decorator: feedDecorator);
    _favoritesBuilder = widget.favoritesBuilder ??
        (favorites) => DefaultGridFeedFavoritesWidget(favorites, widget.feed,
            decorator: feedDecorator);
  }

  /// Fetches a stream of widgets representing the stories in the feed.
  Stream<Iterable<Widget>> _getStoriesWidgets() {
    return FeedStoriesStream(
      feed: widget.feed,
      storyWidgetBuilder: _storyBuilder,
      feedController: _feedController,
      feedFavoritesWidgetBuilder: _favoritesBuilder,
      feedDecorator: feedDecorator,
      onStoriesLoaded: widget.storiesLoaded,
      onScrollToStory: (index, story) async {
        if (feedDecorator?.animateScrollToItems ?? false) {
          await Future.delayed(
            Duration(milliseconds: 300),
            () => observerController.animateTo(
              index: index,
              duration:
                  feedDecorator?.scrollDuration ?? Duration(milliseconds: 300),
              curve: feedDecorator?.scrollCurve ?? Curves.easeInOut,
              padding: feedDecorator?.feedPadding ?? EdgeInsets.zero,
            ),
          );
        } else {
          observerController.jumpTo(
            index: index,
            padding: feedDecorator?.feedPadding ?? EdgeInsets.zero,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _feedStoriesWidgetsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (loaderBuilder == null) {
            return SizedBox.shrink();
          }
          return SizedBox(
            height: widget.height,
            child: loaderBuilder!(context),
          );
        }

        if (snapshot.hasError) {
          if (kDebugMode) {
            print(
                'InAppStory: error while loading feed stories: ${snapshot.error}');
          }
          if (widget.errorBuilder == null) {
            return SizedBox.shrink();
          }
          return SizedBox(
            height: widget.height,
            child: errorBuilder!(context, snapshot.error),
          );
        }

        final storiesWidgets = snapshot.data ?? [];

        if (storiesWidgets.isEmpty) {
          if (kDebugMode) {
            print('InAppStory: no stories found in feed: ${widget.feed}');
          }
          return SizedBox.shrink();
        }

        return SizedBox(
          height: widget.height,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: ListViewObserver(
              controller: observerController,
              child: ListView.separated(
                controller: scrollController,
                itemCount: storiesWidgets.length,
                scrollDirection: Axis.horizontal,
                physics: feedDecorator?.scrollPhysics,
                padding: feedDecorator?.feedPadding,
                itemBuilder: (context, index) {
                  return snapshot.requireData.elementAt(index);
                },
                separatorBuilder: (context, index) =>
                    SizedBox(width: feedDecorator?.storyPadding ?? 8.0),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    (_feedStoriesWidgetsStream as FeedStoriesStream).dispose();
    super.dispose();
  }
}

/// A default widget for displaying a loading shimmer effect.
///
/// This widget is used when the feed is loading and no custom loader builder
/// is provided.
class DefaultLoaderWidget extends StatelessWidget {
  /// Creates a [DefaultLoaderWidget].
  ///
  /// [decorator] is used to customize the appearance of the loader.
  const DefaultLoaderWidget({super.key, required this.decorator});

  /// The decorator for customizing the appearance of the loader.
  final FeedStoryDecorator decorator;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: decorator.feedPadding,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: decorator.loaderDecorator.baseColor,
          highlightColor: decorator.loaderDecorator.highlightColor,
          child: ClipRRect(
            borderRadius: decorator.borderRadius,
            child: AspectRatio(
              aspectRatio: decorator.loaderAspectRatio,
              child: Container(
                width: 100,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: decorator.borderRadius,
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(width: decorator.storyPadding);
      },
      itemCount: 10,
    );
  }
}
