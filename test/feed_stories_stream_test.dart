// ignore_for_file: implicit_call_tearoffs, invalid_use_of_protected_member

import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/generated/pigeon_generated.g.dart'
    show InappstorySdkModuleHostApi, StoryAPIDataDto, StoryDataDto;
import 'package:inappstory_plugin/src/helpers/id_gen.dart';
import 'package:inappstory_plugin/src/widgets/streams/feed_stories_stream.dart';

import 'mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => _stubModuleHostApiChannel());
  tearDown(() => _stubModuleHostApiChannel(remove: true));

  group('GIVEN a stream showing feedA', () {
    late FeedStoriesStream stream;
    late List<String?> loadErrors;
    late List<Map<String, dynamic>> storiesLoadedCalls;
    late List<Map<String, dynamic>> scrollToStoryCalls;

    setUp(() {
      loadErrors = <String?>[];
      storiesLoadedCalls = [];
      scrollToStoryCalls = [];
      stream = FeedStoriesStream(
        feed: 'feedA',
        uniqueId: idGenerator(),
        storyWidgetBuilder: MockStoryWidgetBuilder(),
        onStoriesLoadError: loadErrors.add,
        onStoriesLoaded: (size, feed) => storiesLoadedCalls.add({'size': size, 'feed': feed}),
        onScrollToStory: (index, story) => scrollToStoryCalls.add({'index': index, 'story': story}),
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

    group('GIVEN a stream with stories loaded', () {
      setUp(() {
        stream.updateStoriesData([_storyDto(1)]);
      });

      test('WHEN updateStoryData with matching id THEN story is updated', () {
        // StoryFromPigeonDto.updateStoryData requires a listener on its controller
        stream.stories.first.controller.stream.listen((_) {});

        final updatedDto = _storyDto(1, opened: true);
        stream.updateStoryData(updatedDto);

        expect(stream.stories.first.dto.opened, isTrue);
      });

      test('WHEN updateStoryData with non-matching id THEN stories unchanged', () {
        final originalOpened = stream.stories.first.dto.opened;
        stream.updateStoryData(_storyDto(2, opened: !originalOpened));
        
        expect(stream.stories.first.dto.opened, originalOpened);
        expect(stream.stories.length, 1);
      });
    });

    test('WHEN storiesLoaded called THEN watchdog disarmed and onStoriesLoaded callback fires', () {
      fakeAsync((async) {
        stream.armLoadWatchdog();
        stream.storiesLoaded(1, 'feedA');
        async.elapse(const Duration(seconds: 20)); // watchdog would fire if not disarmed
        
        expect(loadErrors, isEmpty);
        expect(storiesLoadedCalls, [{'size': 1, 'feed': 'feedA'}]);
      });
    });

    group('GIVEN a stream', () {
      setUp(() {
        stream.updateStoriesData([_storyDto(1), _storyDto(2)]);
      });

      test('WHEN scrollToStory with matching uniqueId THEN onScrollToStory called with correct index', () {
        stream.scrollToStory(2, 'feedA', stream.uniqueId);
        expect(scrollToStoryCalls, hasLength(1));
        expect(scrollToStoryCalls.first['index'], 1);
        expect(scrollToStoryCalls.first['story'].id, 2);
      });

      test('WHEN scrollToStory with non-matching uniqueId THEN onScrollToStory not called', () {
        stream.scrollToStory(2, 'feedA', 'otherId');
        expect(scrollToStoryCalls, isEmpty);
      });
    });

    test('WHEN dispose called THEN watchdog disarmed and feedController nulled', () {
      fakeAsync((async) {
        stream.armLoadWatchdog();
        stream.dispose();
        async.elapse(const Duration(seconds: 20));
        
        expect(loadErrors, isEmpty);
        expect(stream.feedController, isNull);
      });
    });
  });
}

StoryAPIDataDto _storyDto(int id, {bool opened = false}) => StoryAPIDataDto(
      id: id,
      storyData: StoryDataDto(id: id, slidesCount: 1),
      hasAudio: false,
      title: 'title',
      titleColor: '#000000',
      backgroundColor: '#FFFFFF',
      opened: opened,
      aspectRatio: 1.0,
    );

void _stubModuleHostApiChannel({bool remove = false}) {
  const prefix =
      'dev.flutter.pigeon.inappstory_plugin.InappstorySdkModuleHostApi';
  const codec = InappstorySdkModuleHostApi.pigeonChannelCodec;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  for (final method in ['createListAdaptor', 'removeListAdaptor']) {
    messenger.setMockMessageHandler(
      '$prefix.$method',
      remove ? null : (_) async => codec.encodeMessage(<Object?>[null]),
    );
  }
}
