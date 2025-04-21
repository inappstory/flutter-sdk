import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/base_story_widget.dart';
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
  });

  final String feed;

  final FeedStoriesController? controller;
  final FeedStoryDecorator? decorator;

  final FeedLoaderWidgetBuilder? loaderBuilder;
  final FeedErrorWidgetBuilder? errorBuilder;
  final StoryWidgetBuilder? storyBuilder;

  @override
  State<FeedStoriesWidget> createState() => _FeedStoriesWidgetState();
}

class _FeedStoriesWidgetState extends State<FeedStoriesWidget> {
  late final _feedStoriesWidgetsStream = _getStoriesWidgets();

  late FeedStoriesController _feedController;

  late FeedLoaderWidgetBuilder _loaderWidgetBuilder;

  late FeedErrorWidgetBuilder _errorWidgetBuilder;
  late StoryWidgetBuilder _storyBuilder;
  late FeedStoryDecorator? _feedDecorator;

  @override
  initState() {
    super.initState();
    _feedController = widget.controller ?? FeedStoriesController();
    _errorWidgetBuilder = widget.errorBuilder ?? (context, error) => Center(child: Text('Error: $error'));
    _feedDecorator = widget.decorator ?? FeedStoryDecorator();
    _loaderWidgetBuilder = widget.loaderBuilder ?? (context) => DefaultLoaderWidget(decorator: _feedDecorator!);
    _storyBuilder = widget.storyBuilder ?? (story, decorator) => StorySimpleDecorator(story, decorator: _feedDecorator);
  }

  Stream<Iterable<Widget>> _getStoriesWidgets() {
    return InAppStoryPlugin().getStoriesWidgets(
      feed: widget.feed,
      storyBuilder: _storyBuilder,
      storiesController: _feedController,
      storiesDecorator: _feedDecorator,
      //favoritesBuilder: (favorites) => CustomGridFeedFavoritesWidget(favorites, onTap: onFeedFavoritesTap),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _feedStoriesWidgetsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loaderWidgetBuilder(context);
        }

        if (snapshot.hasError) {
          return _errorWidgetBuilder(context, snapshot.error);
        }

        final storiesWidgets = snapshot.data ?? [];

        return ListView.separated(
          itemCount: storiesWidgets.length,
          scrollDirection: Axis.horizontal,
          padding: _feedDecorator?.feedPadding,
          itemBuilder: (context, index) {
            return snapshot.requireData.elementAt(index);
          },
          separatorBuilder: (context, index) => const SizedBox(width: 12),
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
