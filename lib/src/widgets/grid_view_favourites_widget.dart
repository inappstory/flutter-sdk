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
    @visibleForTesting this.storiesStream,
  });

  @visibleForTesting
  final Stream<Iterable<Widget>>? storiesStream;

  @override
  FeedStoriesWidgetState createState() => _GridViewFavouritesWidgetState();
}

class _GridViewFavouritesWidgetState extends FeedStoriesWidgetState {
  late final Stream<Iterable<Widget>> _favoritesStoriesWidgetsStream =
      (widget as GridViewFavouritesWidget).storiesStream ??
          _getFavouritesStoriesWidgets();

  bool _isClosing = false;

  Stream<Iterable<Widget>> _getFavouritesStoriesWidgets() {
    return FavoritesStoriesStream(
      feed: widget.feed,
      storyWidgetBuilder: widget.storyBuilder ??
          (story, decorator) => BaseStoryBuilder(story, decorator: decorator),
      feedController: widget.controller,
      feedDecorator: widget.decorator,
      onStoriesLoadError: widget.storiesLoadError,
    );
  }

  void _closeRouteIfEmpty() {
    if (_isClosing) return;
    _isClosing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route != null && route.isActive && route.isCurrent) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Iterable<Widget>>(
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

        final stories = snapshot.data;
        if (stories == null || stories.isEmpty) {
          _closeRouteIfEmpty();
          return const SizedBox.shrink();
        }

        _isClosing = false;

        return GridView.builder(
          itemCount: stories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: widget.decorator?.favouriteAspectRatio ?? 1.0,
          ),
          itemBuilder: (context, index) {
            return stories.elementAt(index);
          },
        );
      },
    );
  }
}
