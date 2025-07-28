import 'package:flutter/material.dart';

import 'streams/favorites_stories_stream.dart';
import 'widgets.dart';

class GridViewFavouritesWidget extends FeedStoriesWidget {
  const GridViewFavouritesWidget({
    super.key,
    required super.feed,
    super.controller,
    super.loaderBuilder,
    super.errorBuilder,
    super.decorator,
    super.storyBuilder,
  });

  @override
  FeedStoriesWidgetState createState() => _GridViewFavouritesWidgetState();
}

class _GridViewFavouritesWidgetState extends FeedStoriesWidgetState {
  late final _favoritesStoriesWidgetsStream = _getFavouritesStoriesWidgets();

  Stream<Iterable<Widget>> _getFavouritesStoriesWidgets() {
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
          return super.loaderBuilder!(context);
        }

        if (snapshot.hasError) {
          if (widget.errorBuilder == null) {
            return const SizedBox.shrink();
          }
          return super.errorBuilder!(context, snapshot.error);
        }

        if ((snapshot.data?.length ?? 0) == 0) {
          Navigator.of(context).pop();
          return SizedBox.shrink();
        }

        return GridView.builder(
          itemCount: snapshot.data?.length ?? 0,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: widget.decorator?.favouriteAspectRatio ?? 1.0,
          ),
          itemBuilder: (context, index) {
            return snapshot.requireData.elementAt(index);
          },
        );
      },
    );
  }
}
