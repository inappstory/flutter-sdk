import 'data/observable.dart';
import 'generated/pigeon_generated.g.dart'
    show
        InAppStoryAPIListSubscriberFlutterApi,
        StoryAPIDataDto,
        StoryFavoriteItemAPIDataDto;

class InAppStoryAPIListSubscriberFlutterApiObservable
    extends Observable<InAppStoryAPIListSubscriberFlutterApi>
    implements InAppStoryAPIListSubscriberFlutterApi {
  InAppStoryAPIListSubscriberFlutterApiObservable(this.uniqueId);

  final String uniqueId;

  @override
  void addObserver(InAppStoryAPIListSubscriberFlutterApi observer) {
    if (observers.isEmpty) {
      InAppStoryAPIListSubscriberFlutterApi.setUp(this,
          messageChannelSuffix: uniqueId);
    }

    super.addObserver(observer);
  }

  @override
  void removeObserver(InAppStoryAPIListSubscriberFlutterApi observer) {
    super.removeObserver(observer);

    if (observers.isEmpty) {
      InAppStoryAPIListSubscriberFlutterApi.setUp(null,
          messageChannelSuffix: uniqueId);
    }
  }

  @override
  Future<void> updateStoriesData(List<StoryAPIDataDto?> list) {
    for (final it in observers) {
      it.updateStoriesData(list);
    }
    return Future.value();
  }

  @override
  Future<void> updateStoryData(StoryAPIDataDto var1) {
    for (final it in observers) {
      it.updateStoryData(var1);
    }
    return Future.value();
  }

  @override
  Future<void> updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto?> list) {
    for (final it in observers) {
      it.updateFavoriteStoriesData(list);
    }
    return Future.value();
  }

  @override
  Future<void> storiesLoaded(int size, String feed) {
    for (final it in observers) {
      it.storiesLoaded(size, feed);
    }
    return Future.value();
  }

  @override
  Future<void> scrollToStory(int index, String feed, String uniqueId) {
    for (final it in observers) {
      it.scrollToStory(index, feed, uniqueId);
    }
    return Future.value();
  }

  @override
  Future<void> storiesUpdateFailure(String feed, String? reason) {
    for (final it in observers) {
      it.storiesUpdateFailure(feed, reason);
    }
    return Future.value();
  }
}
