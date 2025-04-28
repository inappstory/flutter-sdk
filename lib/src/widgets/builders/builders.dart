import 'package:flutter/widgets.dart';

import '../../data/story.dart';
import '../base/story_widget.dart';
import '../decorators/feed_decorator.dart';

typedef FeedErrorWidgetBuilder = Widget Function(
  BuildContext context,
  Object? error,
);
typedef FeedLoaderWidgetBuilder = Widget Function(BuildContext context);

typedef FeedStoryWidgetBuilder = StoryWidget Function(
  Story story, {
  FeedStoryDecorator? decorator,
});

typedef StoryWidgetBuilder = Widget Function(Story story, FeedStoryDecorator decorator);
