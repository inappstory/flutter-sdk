import 'package:flutter/foundation.dart';

import '../pigeon_generated.g.dart';

/// A controller for managing feed stories.
class FeedStoriesController {
  FeedStoriesController();

  IASStoryListHostApi? _iasStoryListHostApi;

  set iasStoryListHostApi(IASStoryListHostApi hostApi) {
    _iasStoryListHostApi = hostApi;
  }

  String? _feed;

  set feed(String value) {
    _feed = value;
  }

  /// Loads stories from the current feed.
  Future<void> fetchFeedStories() async {
    // TODO: 08.05.2025 Add Exception
    if (_feed?.isEmpty ?? true) {
      if (kDebugMode) {
        print(
            '[InAppStory]: Feed is not set. Please set the feed before calling fetchFeedStories');
      }
      return;
    }
    if (_iasStoryListHostApi == null) {
      // TODO: 08.05.2025 Add Exception
      if (kDebugMode) {
        print(
            '[InAppStory]: Add controller to feed stream before calling fetchFeedStories');
      }
      return;
    }
    _iasStoryListHostApi?.reloadFeed(_feed!);
  }
}
