// ignore_for_file: implicit_call_tearoffs, invalid_use_of_protected_member

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/generated/pigeon_generated.g.dart'
    show StoryAPIDataDto, StoryDataDto;
import 'package:inappstory_plugin/src/helpers/id_gen.dart';
import 'package:inappstory_plugin/src/widgets/streams/feed_stories_stream.dart';

import 'mocks.dart';

void main() {
  group('GIVEN a stream showing feedA', () {
    late FeedStoriesStream stream;
    late List<String?> loadErrors;

    setUp(() {
      loadErrors = <String?>[];
      stream = FeedStoriesStream(
        feed: 'feedA',
        uniqueId: idGenerator(),
        storyWidgetBuilder: MockStoryWidgetBuilder(),
        onStoriesLoadError: loadErrors.add,
      );
    });

    group('WHEN the widget switches it to feedB', () {
      setUp(() => stream.feed = 'feedB');

      test('THEN failures of the new feed are reported', () {
        stream.storiesUpdateFailure('feedB', 'boom');

        expect(loadErrors, ['boom']);
      });

      test('THEN failures of the abandoned feed are ignored', () {
        stream.storiesUpdateFailure('feedA', 'boom');

        expect(loadErrors, isEmpty);
      });

      test('THEN stories are stamped with the new feed', () {
        stream.updateStoriesData([_storyDto(1)]);

        expect(stream.stories.single.feed, 'feedB');
      });
    });

    group('WHEN the SDK never calls back after a load starts', () {
      test('THEN a timeout failure surfaces once the grace period passes', () {
        fakeAsync((async) {
          stream.armLoadWatchdog();
          async.elapse(const Duration(seconds: 20));

          expect(loadErrors, hasLength(1));
          expect(loadErrors.single, contains('timeout'));
        });
      });

      test('THEN a reply before the grace period cancels the timeout', () {
        fakeAsync((async) {
          stream.armLoadWatchdog();
          async.elapse(const Duration(seconds: 5));
          stream.updateStoriesData([_storyDto(1)]);
          async.elapse(const Duration(seconds: 20));

          expect(loadErrors, isEmpty);
        });
      });
    });
  });
}

StoryAPIDataDto _storyDto(int id) => StoryAPIDataDto(
      id: id,
      storyData: StoryDataDto(id: id, slidesCount: 1),
      hasAudio: false,
      title: 'title',
      titleColor: '#000000',
      backgroundColor: '#FFFFFF',
      opened: false,
      aspectRatio: 1.0,
    );
