import 'package:flutter/services.dart';

import 'pigeon_generated.g.dart';

class IASStoryListHostApiDecorator implements IASStoryListHostApi {
  IASStoryListHostApiDecorator(this.decorated);

  final IASStoryListHostApi decorated;

  final syncCalledUpdateIds = <int>[];

  @override
  Future<void> updateVisiblePreviews(List<int?> storyIds) async {
    syncCalledUpdateIds.addAll(storyIds.whereType<int>());

    await Future.delayed(Duration.zero);

    if (syncCalledUpdateIds.isEmpty) return;

    final ids = List.of(syncCalledUpdateIds);

    syncCalledUpdateIds.clear();

    return decorated.updateVisiblePreviews(ids);
  }

  @override
  Future<void> load(String feed, bool hasFavorite, bool isFavorite) {
    return decorated.load(feed, hasFavorite, isFavorite);
  }

  @override
  Future<void> openStoryReader(int storyId) {
    return decorated.openStoryReader(storyId);
  }

  @override
  Future<void> showFavoriteItem() {
    return decorated.showFavoriteItem();
  }

  @override
  BinaryMessenger? get pigeonVar_binaryMessenger => decorated.pigeonVar_binaryMessenger;

  @override
  String get pigeonVar_messageChannelSuffix => decorated.pigeonVar_messageChannelSuffix;
}
