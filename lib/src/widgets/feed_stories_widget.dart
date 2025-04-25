import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/base_story_widget.dart';
import 'package:inappstory_plugin/src/widgets/decorators/custom_grid_feed_favorites_widget.dart';
import 'package:shimmer/shimmer.dart';

import 'builders/feed_builders.dart';
import 'decorators/story_widget_simple_decorator.dart';

class FeedStoriesWidget extends StatefulWidget {
  const FeedStoriesWidget({
    super.key,
    required this.feed,
    this.controller,
    this.loaderBuilder,
    this.errorBuilder,
    this.decorator,
    this.storyBuilder,
    this.favoritesBuilder,
  });

  final String feed;

  final FeedStoriesController? controller;
  final FeedStoryDecorator? decorator;

  final FeedLoaderWidgetBuilder? loaderBuilder;
  final FeedErrorWidgetBuilder? errorBuilder;
  final StoryWidgetBuilder? storyBuilder;
  final FeedFavoritesWidgetBuilder? favoritesBuilder;

  @override
  State<FeedStoriesWidget> createState() => FeedStoriesWidgetState();
}

class FeedStoriesWidgetState extends State<FeedStoriesWidget> {
  late final _feedStoriesWidgetsStream = _getStoriesWidgets();

  late FeedStoriesController _feedController;

  late FeedLoaderWidgetBuilder loaderWidgetBuilder;

  late FeedErrorWidgetBuilder errorWidgetBuilder;

  late FeedFavoritesWidgetBuilder _favoritesBuilder;
  late StoryWidgetBuilder _storyBuilder;
  late FeedStoryDecorator? feedDecorator;

  @override
  initState() {
    super.initState();
    _feedController = widget.controller ?? FeedStoriesController();
    errorWidgetBuilder = widget.errorBuilder ?? (context, error) => Center(child: Text('Error: $error'));
    feedDecorator = widget.decorator ?? FeedStoryDecorator();
    loaderWidgetBuilder = widget.loaderBuilder ?? (context) => DefaultLoaderWidget(decorator: feedDecorator!);
    _storyBuilder = widget.storyBuilder ?? (story, decorator) => StorySimpleDecorator(story, decorator: feedDecorator);
    _favoritesBuilder = widget.favoritesBuilder ??
        (favorites) => CustomGridFeedFavoritesWidget(
              favorites,
              onTap: () {},
            );
  }

  Stream<Iterable<Widget>> _getStoriesWidgets() {
    return FeedStoriesStream(
      feed: widget.feed,
      storyWidgetBuilder: _storyBuilder,
      feedController: _feedController,
      feedFavoritesWidgetBuilder: _favoritesBuilder,
      feedDecorator: feedDecorator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _feedStoriesWidgetsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loaderWidgetBuilder(context);
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
          separatorBuilder: (context, index) => SizedBox(width: feedDecorator?.storyPadding ?? 12),
        );
      },
    );
  }
}

class DefaultLoaderWidget extends StatelessWidget {
  const DefaultLoaderWidget({super.key, required this.decorator});

  final FeedStoryDecorator decorator;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: decorator.feedPadding,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: decorator.loaderDecorator.baseColor ?? Colors.grey.shade300,
          highlightColor: decorator.loaderDecorator.highlightColor ?? Colors.grey.shade500,
          child: Container(
            width: 100,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: decorator.borderRadius,
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
