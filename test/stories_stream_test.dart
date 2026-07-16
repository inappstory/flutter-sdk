// ignore_for_file: implicit_call_tearoffs, invalid_use_of_protected_member

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart'
    show
        FeedStoriesController,
        InAppStoryAPIListSubscriberFlutterApi,
        StoryAPIDataDto;
import 'package:inappstory_plugin/src/helpers/id_gen.dart';
import 'package:inappstory_plugin/src/widgets/streams/stories_stream.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  group('GIVEN new instance for feedID', () {
    final feed = 'feedID';
    final uniqueId = idGenerator();

    late StoriesStream storiesStream;
    late MockObservable<InAppStoryAPIListSubscriberFlutterApi>
        observableStoryList;
    late MockIASStoryListHostApi iasStoryListHostApi;

    setUp(() {
      storiesStream = _TestStoriesStream(
        feed: feed,
        uniqueId: 'uniqueId',
        storyWidgetBuilder: MockStoryWidgetBuilder(),
        observableStoryList: observableStoryList = MockObservable(),
        iasStoryListHostApi: iasStoryListHostApi = MockIASStoryListHostApi(),
        storyDecorator: MockStoryDecorator(),
      );

      when(() => iasStoryListHostApi.load(feed, uniqueId))
          .thenAnswer((_) async {});
    });

    group('WHEN got client', () {
      setUp(() => storiesStream.listen((_) {}));

      test('THEN api subscribed', () {
        verify(() => observableStoryList.addObserver(storiesStream)).called(1);
        verify(() => iasStoryListHostApi.load(feed, uniqueId)).called(1);
      });
    });

    group('WHEN no client', () {
      test('THEN api never called', () {
        verifyZeroInteractions(observableStoryList);
        verifyZeroInteractions(iasStoryListHostApi);
      });
    });

    group('AND a controller is bound to it', () {
      late FeedStoriesController feedController;

      setUp(() {
        storiesStream.feedController = feedController = FeedStoriesController();
        when(() => iasStoryListHostApi.reloadFeed(any()))
            .thenAnswer((_) async {});
      });

      group('WHEN the widget switches the stream to another feed', () {
        setUp(() => storiesStream.feed = 'otherFeedID');

        test('THEN the controller reloads the feed shown now', () async {
          await feedController.fetchFeedStories();

          verify(() => iasStoryListHostApi.reloadFeed('otherFeedID')).called(1);
          verifyNever(() => iasStoryListHostApi.reloadFeed(feed));
        });
      });
    });

    group('WHEN the SDK silently drops the load (no callback ever fires)', () {
      test('THEN the stream eventually reports a timeout failure', () {
        fakeAsync((async) {
          final failures = <String?>[];
          final watchedStream = _TestStoriesStream(
            feed: feed,
            uniqueId: 'uniqueId',
            storyWidgetBuilder: MockStoryWidgetBuilder(),
            observableStoryList: observableStoryList,
            iasStoryListHostApi: iasStoryListHostApi,
            storyDecorator: MockStoryDecorator(),
            onFailure: (_, reason) => failures.add(reason),
          );

          watchedStream.armLoadWatchdog();
          async.elapse(const Duration(seconds: 20));

          expect(failures, hasLength(1));
          expect(failures.single, contains('timeout'));
        });
      });
    });

    group('AND has client', () {
      late StreamSubscription subscription;
      setUp(() => subscription = storiesStream.listen((_) {}));

      group('WHEN client cancels', () {
        setUp(() => subscription.cancel());

        // test('THEN api unsubscribed', () {
        //   verify(() => observableErrorCallback.removeObserver(storiesStream))
        //       .called(1);
        // });
      });
    });
  });
}

class _TestStoriesStream extends StoriesStream {
  _TestStoriesStream({
    required super.feed,
    required super.uniqueId,
    required super.storyWidgetBuilder,
    required super.observableStoryList,
    required super.iasStoryListHostApi,
    required super.storyDecorator,
    this.onFailure,
  });

  final void Function(String feed, String? reason)? onFailure;

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {}

  @override
  void updateStoryData(StoryAPIDataDto story) {}

  @override
  void storiesLoaded(int size, String feed) {}

  @override
  void scrollToStory(int index, String feed, String uniqueId) {}

  @override
  void storiesUpdateFailure(String feed, String? reason) =>
      onFailure?.call(feed, reason);
}
