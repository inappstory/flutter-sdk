// ignore_for_file: implicit_call_tearoffs

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/pigeon_generated.g.dart';
import 'package:inappstory_plugin/src/widgets/streams/stories_stream.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  group('GIVEN new instance for feedID', () {
    const feed = 'feedID';

    late StoriesStream storiesStream;
    late MockObservable<InAppStoryAPIListSubscriberFlutterApi> observableStoryList;
    late MockObservable<ErrorCallbackFlutterApi> observableErrorCallback;
    late MockIASStoryListHostApi iasStoryListHostApi;

    setUp(() {
      storiesStream = _TestStoriesStream(
        feed: feed,
        uniqueId: 'uniqueId',
        storyWidgetBuilder: MockStoryWidgetBuilder(),
        observableStoryList: observableStoryList = MockObservable(),
        observableErrorCallback: observableErrorCallback = MockObservable(),
        iasStoryListHostApi: iasStoryListHostApi = MockIASStoryListHostApi(),
        storyDecorator: MockStoryDecorator(),
      );

      when(() => iasStoryListHostApi.load(feed)).thenAnswer((_) async {});
    });

    group('WHEN got client', () {
      setUp(() => storiesStream.listen((_) {}));

      test('THEN api subscribed', () {
        verify(() => observableStoryList.addObserver(storiesStream)).called(1);
        verify(() => observableErrorCallback.addObserver(storiesStream)).called(1);
        verify(() => iasStoryListHostApi.load(feed)).called(1);
      });
    });

    group('WHEN no client', () {
      test('THEN api never called', () {
        verifyZeroInteractions(observableStoryList);
        verifyZeroInteractions(observableErrorCallback);
        verifyZeroInteractions(iasStoryListHostApi);
      });
    });

    group('AND has client', () {
      late StreamSubscription subscription;
      setUp(() => subscription = storiesStream.listen((_) {}));

      group('WHEN client cancels', () {
        setUp(() => subscription.cancel());

        test('THEN api unsubscribed', () {
          verify(() => observableErrorCallback.removeObserver(storiesStream)).called(1);
        });
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
    required super.observableErrorCallback,
    required super.iasStoryListHostApi,
    required super.storyDecorator,
  });

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {}

  @override
  void updateStoryData(StoryAPIDataDto story) {}
}
