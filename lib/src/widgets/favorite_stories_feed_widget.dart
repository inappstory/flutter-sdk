import 'package:flutter/widgets.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/favorites_stories_stream.dart';

import 'decorators/story_widget_simple_decorator.dart';

class FavoriteStoriesFeedWidget extends FeedStoriesWidget {
  const FavoriteStoriesFeedWidget({
    super.key,
    required super.feed,
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
      storyWidgetBuilder:
          widget.storyBuilder ?? (story, decorator) => StorySimpleDecorator(story, decorator: decorator),
      feedController: widget.controller,
      //feedFavoritesWidgetBuilder: favoritesBuilder,
      feedDecorator: widget.decorator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _favoritesStoriesWidgetsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return super.loaderWidgetBuilder(context);
        }

        if (snapshot.hasError) {
          return errorWidgetBuilder(context, snapshot.error);
        }

        final storiesWidgets = snapshot.data ?? [];

        return ListView.separated(
          itemCount: storiesWidgets.length,
          scrollDirection: Axis.horizontal,
          padding: feedDecorator?.feedPadding,
          itemBuilder: (context, index) {
            return snapshot.requireData.elementAt(index);
          },
          separatorBuilder: (context, index) => const SizedBox(width: 12),
        );
      },
    );
  }
}
