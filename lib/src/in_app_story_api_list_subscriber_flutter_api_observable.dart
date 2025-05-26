import 'data/observable.dart';
import 'pigeon_generated.g.dart';

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
  void updateStoriesData(List<StoryAPIDataDto> list) {
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
  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto> list) {
    for (var it in observers) {
      it.updateFavoriteStoriesData(list);
    }
  }

  @override
  void storiesLoaded(int size, String feed) {
    for (var it in observers) {
      it.storiesLoaded(size, feed);
    }
  }
}
