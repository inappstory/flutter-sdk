import 'package:flutter/widgets.dart';

import '../../story.dart';
import '../decorators/feed_decorator.dart';
import '../story_widget.dart';

typedef FeedErrorWidgetBuilder = Widget Function(
  BuildContext context,
  Object? error,
);
typedef FeedLoaderWidgetBuilder = Widget Function(BuildContext context);

typedef FeedStoryWidgetBuilder = StoryWidget Function(
  Story story, {
  FeedStoryDecorator? decorator,
});
