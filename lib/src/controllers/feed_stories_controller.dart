import 'dart:developer';

import 'package:meta/meta.dart';

typedef FeedReloadCallback = Future<void> Function();

/// A controller for managing feed stories.
class FeedStoriesController {
  FeedStoriesController();

  FeedReloadCallback? _reload;

  @protected
  void attach(FeedReloadCallback reload) {
    _reload = reload;
  }

  @protected
  void detach(FeedReloadCallback reload) {
    if (identical(_reload, reload)) {
      _reload = null;
    }
  }

  /// Loads stories from the current feed.
  Future<void> fetchFeedStories() async {
    final reload = _reload;
    if (reload == null) {
      log('[InAppStory]: fetchFeedStories skipped: no FeedStoriesWidget is '
          'attached to this controller. The feed loads when one mounts.');
      return;
    }
    await reload();
  }
}
