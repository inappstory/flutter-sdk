import 'dart:developer';

import 'package:meta/meta.dart';

import '../../inappstory_plugin.dart';

/// A controller for managing feed stories.
class FeedStoriesController {
  FeedStoriesController();

  IASStoryListHostApi? _iasStoryListHostApi;

  @protected
  set iasStoryListHostApi(IASStoryListHostApi hostApi) {
    _iasStoryListHostApi = hostApi;
  }

  String? _feed;

  set feed(String value) {
    _feed = value;
  }

  /// Reloads stories from the current feed.
  Future<void> fetchFeedStories() async {
    InAppStoryManager.instance.logger.flutterDebugLog(
        'FeedStoriesController', 'reloading feed stories from feed: $_feed');
    // TODO: 08.05.2025 Add Exception
    if (_feed?.isEmpty ?? true) {
      log('[InAppStory]: Feed is not set. Please set the feed before calling fetchFeedStories');
      return;
    }
    if (_iasStoryListHostApi == null) {
      // TODO: 08.05.2025 Add Exception
      log('[InAppStory]: Add controller to feed stream before calling fetchFeedStories');
      return;
    }
    _iasStoryListHostApi?.reloadFeed(_feed!);
  }
}
