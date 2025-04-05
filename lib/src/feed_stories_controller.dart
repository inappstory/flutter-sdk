import 'pigeon_generated.g.dart';

/// A controller for managing feed stories.
class FeedStoriesController {
  FeedStoriesController();

  late IASStoryListHostApi? _iasStoryListHostApi;

  set iasStoryListHostApi(IASStoryListHostApi hostApi) {
    _iasStoryListHostApi = hostApi;
  }

  late String? _feed;

  set feed(String value) {
    _feed = value;
  }

  /// Loads stories from the current feed.
  Future<void> fetchFeedStories() async {
    if (_feed?.isEmpty ?? true) {
      throw Exception('Feed is not set. Please set the feed before calling fetchFeedStories');
    }
    if (_iasStoryListHostApi == null) {
      throw Exception('Add controller to feed stream before calling fetchFeedStories');
    }
    _iasStoryListHostApi?.load(_feed!);
  }
}
