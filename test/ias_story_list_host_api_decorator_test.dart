import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/ias_story_list_host_api_decorator.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  group('$IASStoryListHostApiDecorator', () {
    late MockIASStoryListHostApi mockDecorated;
    late IASStoryListHostApiDecorator decorator;

    setUp(() {
      mockDecorated = MockIASStoryListHostApi();
      decorator = IASStoryListHostApiDecorator(mockDecorated);
    });

    group('GIVEN decorator', () {
      test('WHEN updateVisiblePreviews called once THEN decorated receives the ids after microtask', () {
        fakeAsync((async) {
          when(() => mockDecorated.updateVisiblePreviews(any(), any())).thenAnswer((_) async {});
          decorator.updateVisiblePreviews([1, 2], 'feed');
          async.elapse(Duration.zero);
          verify(() => mockDecorated.updateVisiblePreviews([1, 2], 'feed')).called(1);
        });
      });

      test('WHEN updateVisiblePreviews called twice synchronously THEN decorated receives batched ids in single call', () {
        fakeAsync((async) {
          when(() => mockDecorated.updateVisiblePreviews(any(), any())).thenAnswer((_) async {});
          decorator.updateVisiblePreviews([1, 2], 'feed');
          decorator.updateVisiblePreviews([3, 4], 'feed');
          async.elapse(Duration.zero);
          verify(() => mockDecorated.updateVisiblePreviews([1, 2, 3, 4], 'feed')).called(1);
        });
      });

      test('WHEN updateVisiblePreviews called with list containing nulls THEN null values are filtered out', () {
        fakeAsync((async) {
          when(() => mockDecorated.updateVisiblePreviews(any(), any())).thenAnswer((_) async {});
          decorator.updateVisiblePreviews([1, null, 2], 'feed');
          async.elapse(Duration.zero);
          verify(() => mockDecorated.updateVisiblePreviews([1, 2], 'feed')).called(1);
        });
      });

      test('WHEN reloadFeed called THEN delegates to decorated', () async {
        when(() => mockDecorated.reloadFeed('feed')).thenAnswer((_) async {});
        await decorator.reloadFeed('feed');
        verify(() => mockDecorated.reloadFeed('feed')).called(1);
      });
    });

    group('GIVEN decorated throws PlatformException with channel-error', () {
      test('WHEN updateVisiblePreviews THEN error is suppressed and completed normally', () {
        fakeAsync((async) {
          when(() => mockDecorated.updateVisiblePreviews(any(), any())).thenThrow(PlatformException(code: 'channel-error'));
          decorator.updateVisiblePreviews([1], 'feed');
          async.elapse(Duration.zero);
          verify(() => mockDecorated.updateVisiblePreviews([1], 'feed')).called(1);
        });
      });
    });

    group('GIVEN decorated throws PlatformException with other code', () {
      test('WHEN updateVisiblePreviews THEN error is rethrown', () async {
        when(() => mockDecorated.updateVisiblePreviews(any(), any())).thenThrow(PlatformException(code: 'other-error'));
        final future = decorator.updateVisiblePreviews([1], 'feed');
        await expectLater(future, throwsA(isA<PlatformException>()));
      });
    });
  });
}
