import 'observable.dart';
import 'pigeon_generated.g.dart';

class InAppStoryAPIListSubscriberFlutterApiObservable extends Observable<InAppStoryAPIListSubscriberFlutterApi>
    implements InAppStoryAPIListSubscriberFlutterApi {
  InAppStoryAPIListSubscriberFlutterApiObservable(this.uniqueId);

  final String uniqueId;

  @override
  void addObserver(InAppStoryAPIListSubscriberFlutterApi observer) {
    if (observers.isEmpty) InAppStoryAPIListSubscriberFlutterApi.setUp(this, messageChannelSuffix: uniqueId);

    super.addObserver(observer);
  }

  @override
  void removeObserver(InAppStoryAPIListSubscriberFlutterApi observer) {
    super.removeObserver(observer);

    if (observers.isEmpty) InAppStoryAPIListSubscriberFlutterApi.setUp(null, messageChannelSuffix: uniqueId);
  }

  @override
  void readerIsClosed() {
    for (var it in observers) {
      it.readerIsClosed();
    }
  }

  @override
  void readerIsOpened() {
    for (var it in observers) {
      it.readerIsOpened();
    }
  }

  @override
  void storyIsOpened(int var1) {
    for (var it in observers) {
      it.storyIsOpened(var1);
    }
  }

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {
    for (var it in observers) {
      it.updateStoriesData(list);
    }
  }

  @override
  void updateStoryData(StoryAPIDataDto var1) {
    for (var it in observers) {
      it.updateStoryData(var1);
    }
  }

  @override
  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto?> list) {
    for (var it in observers) {
      it.updateFavoriteStoriesData(list);
    }
  }
}
