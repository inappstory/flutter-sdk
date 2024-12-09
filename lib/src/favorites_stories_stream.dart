import 'pigeon_generated.g.dart';
import 'stories_stream.dart';

class FavoritesStoriesStream extends StoriesStream {
  FavoritesStoriesStream({
    required super.feed,
    required super.storyWidgetBuilder,
  }) : super(uniqueId: "favorites");

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {
    stories = list.whereType<StoryAPIDataDto>().map(createStoryFromDto).toList(growable: false);

    controller.add(stories.map(createWidgetFromStory).toList());
  }
}
