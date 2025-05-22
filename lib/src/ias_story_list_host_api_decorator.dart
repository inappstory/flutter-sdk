import 'package:flutter/services.dart';

import 'pigeon_generated.g.dart';

class IASStoryListHostApiDecorator implements IASStoryListHostApi {
  IASStoryListHostApiDecorator(this.decorated);

  final IASStoryListHostApi decorated;

  final syncCalledUpdateIds = <int>[];

  @override
  Future<void> updateVisiblePreviews(List<int?> storyIds, String feed) async {
    syncCalledUpdateIds.addAll(storyIds.whereType<int>());

    await Future.delayed(Duration.zero);

    if (syncCalledUpdateIds.isEmpty) return;

    final ids = List.of(syncCalledUpdateIds);

    syncCalledUpdateIds.clear();

    return decorated.updateVisiblePreviews(ids, feed);
  }

  @override
  Future<void> load(String feed, {bool hasFavourites = false}) {
    return decorated.load(feed);
  }

  @override
  Future<void> openStoryReader(int storyId, String feed) {
    return decorated.openStoryReader(storyId, feed);
  }

  @override
  Future<void> showFavoriteItem(String feed) {
    return decorated.showFavoriteItem(feed);
  }

  @override
  BinaryMessenger? get pigeonVar_binaryMessenger =>
      decorated.pigeonVar_binaryMessenger;

  @override
  String get pigeonVar_messageChannelSuffix =>
      decorated.pigeonVar_messageChannelSuffix;

  @override
  Future<void> reloadFeed(String feed) {
    return decorated.reloadFeed(feed);
  }

  @override
  Future<void> removeSubscriber(String feed) {
    return decorated.removeSubscriber(feed);
  }
}
