import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/generated/pigeon_generated.g.dart'
    show
        InAppStoryAPIListSubscriberFlutterApi,
        StoryAPIDataDto,
        StoryFavoriteItemAPIDataDto;
import 'package:inappstory_plugin/src/in_app_story_api_list_subscriber_flutter_api_observable.dart';

class RecordingSubscriber implements InAppStoryAPIListSubscriberFlutterApi {
  final calls = <String>[];
  @override
  void updateStoriesData(List<StoryAPIDataDto> list) =>
      calls.add('updateStoriesData');
  @override
  void updateStoryData(StoryAPIDataDto var1) => calls.add('updateStoryData');
  @override
  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto> list) =>
      calls.add('updateFavoriteStoriesData');
  @override
  void storiesLoaded(int size, String feed) => calls.add('storiesLoaded');
  @override
  void scrollToStory(int index, String feed, String uniqueId) =>
      calls.add('scrollToStory');
  @override
  void storiesUpdateFailure(String feed, String? reason) =>
      calls.add('storiesUpdateFailure');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$InAppStoryAPIListSubscriberFlutterApiObservable', () {
    late InAppStoryAPIListSubscriberFlutterApiObservable observable;

    setUp(() {
      observable = InAppStoryAPIListSubscriberFlutterApiObservable('test-id');
    });

    group('GIVEN observable', () {
      test('WHEN first observer added THEN pigeon setUp completes', () {
        final observer = RecordingSubscriber();
        expect(() => observable.addObserver(observer), returnsNormally);
      });
    });

    group('GIVEN observable with one observer', () {
      late RecordingSubscriber observer;

      setUp(() {
        observer = RecordingSubscriber();
        observable.addObserver(observer);
      });

      test('WHEN that observer is removed THEN dispatches no longer reach it', () {
        observable.removeObserver(observer);
        observable.storiesLoaded(10, 'feed');
        expect(observer.calls, isEmpty);
      });

      test('WHEN storiesLoaded dispatched THEN observer receives the call',
          () {
        observable.storiesLoaded(10, 'feed');
        expect(observer.calls, ['storiesLoaded']);
      });
    });

    group('GIVEN two observers', () {
      late RecordingSubscriber observer1;
      late RecordingSubscriber observer2;

      setUp(() {
        observer1 = RecordingSubscriber();
        observer2 = RecordingSubscriber();
        observable.addObserver(observer1);
        observable.addObserver(observer2);
      });

      test(
          'WHEN updateStoriesData dispatched THEN both observers receive the call',
          () {
        observable.updateStoriesData([]);
        expect(observer1.calls, ['updateStoriesData']);
        expect(observer2.calls, ['updateStoriesData']);
      });

      test(
          'WHEN storiesUpdateFailure dispatched THEN both observers receive the call',
          () {
        observable.storiesUpdateFailure('feed', null);
        expect(observer1.calls, ['storiesUpdateFailure']);
        expect(observer2.calls, ['storiesUpdateFailure']);
      });
    });
  });
}
