import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'builders/base_story_builder.dart';
import 'feed_stories_widget.dart';
import 'streams/favorites_stories_stream.dart';

class FavoriteStoriesFeedWidget extends FeedStoriesWidget {
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
          if (kDebugMode) {
            print('InAppStory: no stories found in feed: ${widget.feed}');
          }
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
