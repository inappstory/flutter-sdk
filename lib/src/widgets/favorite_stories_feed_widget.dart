import 'dart:developer';

import 'package:flutter/widgets.dart';

import 'builders/base_story_builder.dart';
import 'feed_stories_widget.dart';
import 'streams/favorites_stories_stream.dart';

/// Displays the user's favorite stories from a feed in a horizontal list.
///
/// Shows nothing while loading or on error unless [loaderBuilder] or
/// [errorBuilder] is set, and shows nothing if there are no favorites.
class FavoriteStoriesFeedWidget extends FeedStoriesWidget {
  /// Creates a list of favorite stories from [feed].
  ///
  /// * [feed]: the ID of the feed to show favorites from.
  /// * [height]: the height of the list. Defaults to 120.0.
  /// * [controller]: reloads the stories on demand.
  /// * [loaderBuilder]: builds the widget shown while loading.
  /// * [errorBuilder]: builds the widget shown if loading fails.
  /// * [decorator]: customizes the appearance of the list and its items.
  /// * [storyBuilder]: builds each story item. Defaults to the SDK's story
  ///   cell.
  const FavoriteStoriesFeedWidget({
    super.key,
    required super.feed,
    super.height = 120.0,
    super.controller,
    super.loaderBuilder,
    super.errorBuilder,
    super.decorator,
    super.storyBuilder,
  });

  @override
  FeedStoriesWidgetState createState() => _FavoriteStoriesFeedWidgetState();
}

class _FavoriteStoriesFeedWidgetState extends FeedStoriesWidgetState {
  late final _favoritesStoriesWidgetsStream = _getStoriesWidgets();

  Stream<Iterable<Widget>> _getStoriesWidgets() {
    return FavoritesStoriesStream(
      feed: widget.feed,
      storyWidgetBuilder: widget.storyBuilder ??
          (story, decorator) => BaseStoryBuilder(story, decorator: decorator),
      feedController: widget.controller,
      feedDecorator: widget.decorator,
      onStoriesLoadError: widget.storiesLoadError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _favoritesStoriesWidgetsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (widget.loaderBuilder == null) {
            return const SizedBox.shrink();
          }
          return SizedBox(
            height: widget.height,
            child: super.loaderBuilder!(context),
          );
        }

        if (snapshot.hasError) {
          if (widget.errorBuilder == null) {
            return const SizedBox.shrink();
          }
          return SizedBox(
            height: widget.height,
            child: super.errorBuilder!(context, snapshot.error),
          );
        }

        final storiesWidgets = snapshot.data ?? [];

        if (storiesWidgets.isEmpty) {
          log('InAppStory: no stories found in feed: ${widget.feed}');
          return SizedBox.shrink();
        }

        return SizedBox(
          height: widget.height,
          child: ListView.separated(
            itemCount: storiesWidgets.length,
            scrollDirection: Axis.horizontal,
            padding: feedDecorator?.feedPadding,
            itemBuilder: (context, index) {
              return snapshot.requireData.elementAt(index);
            },
            separatorBuilder: (context, index) => SizedBox(
              width: feedDecorator?.storyPadding ?? 12.0,
            ),
          ),
        );
      },
    );
  }
}
