// ignore_for_file: invalid_use_of_protected_member
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/data/story_from_pigeon_dto.dart';
import 'package:inappstory_plugin/src/generated/pigeon_generated.g.dart';

import 'mocks.dart';

void main() {
  group('GIVEN nullableFileFromString', () {
    test('WHEN path is null THEN returns null', () {
      expect(nullableFileFromString(null), isNull);
    });

    test('WHEN path is empty THEN returns null', () {
      expect(nullableFileFromString('   '), isNull);
    });

    test('WHEN path is valid THEN returns File', () {
      final file = nullableFileFromString('/path/to/file');
      expect(file, isNotNull);
      expect(file!.path, equals('/path/to/file'));
    });
  });

  group('GIVEN colorFromString', () {
    test('WHEN empty THEN returns transparent', () {
      expect(colorFromString(''), equals(const Color(0x00000000)));
    });

    test('WHEN valid hex THEN returns Color', () {
      expect(colorFromString('#FFFFFF'), equals(const Color(0xFFFFFFFF)));
      expect(colorFromString('#000000'), equals(const Color(0xFF000000)));
      expect(colorFromString('#FF0000'), equals(const Color(0xFFFF0000)));
    });
  });

  group('$StoryFromPigeonDto', () {
    late StoryFromPigeonDto story;
    late StoryAPIDataDto dto;
    late MockIASStoryListHostApi mockApi;
    late MockObservable<InAppStoryAPIListSubscriberFlutterApi> mockObservable;

    setUp(() {
      dto = StoryAPIDataDto(
        id: 1,
        storyData: StoryDataDto(id: 1, slidesCount: 1),
        hasAudio: false,
        title: 'title',
        titleColor: '#000000',
        backgroundColor: '#FFFFFF',
        opened: false,
        aspectRatio: 1.0,
      );
      mockApi = MockIASStoryListHostApi();
      mockObservable = MockObservable<InAppStoryAPIListSubscriberFlutterApi>();
      story = StoryFromPigeonDto(dto, 'feed', mockApi, mockObservable);
    });

    group('WHEN compared for equality', () {
      test('THEN same id are equal', () {
        final dto2 = StoryAPIDataDto(
          id: 1,
          storyData: StoryDataDto(id: 1, slidesCount: 1),
          hasAudio: false,
          title: 'title2',
          titleColor: '#000000',
          backgroundColor: '#FFFFFF',
          opened: false,
          aspectRatio: 1.0,
        );
        final story2 = StoryFromPigeonDto(dto2, 'feed', mockApi, mockObservable);
        expect(story, equals(story2));
      });

      test('AND different id are not equal', () {
        final dto2 = StoryAPIDataDto(
          id: 2,
          storyData: StoryDataDto(id: 2, slidesCount: 1),
          hasAudio: false,
          title: 'title2',
          titleColor: '#000000',
          backgroundColor: '#FFFFFF',
          opened: false,
          aspectRatio: 1.0,
        );
        final story2 = StoryFromPigeonDto(dto2, 'feed', mockApi, mockObservable);
        expect(story, isNot(equals(story2)));
      });
    });

    group('WHEN getting properties', () {
      test('THEN hashCode returns 1', () {
        expect(story.hashCode, 1);
      });
    });

    group('WHEN updateStoryData is called', () {
      test('AND id matches and has listener THEN emits on controller', () {
        fakeAsync((async) {
          final newDto = StoryAPIDataDto(
            id: 1,
            storyData: StoryDataDto(id: 1, slidesCount: 1),
            hasAudio: true,
            title: 'title',
            titleColor: '#000000',
            backgroundColor: '#FFFFFF',
            opened: true,
            aspectRatio: 1.0,
          );

          bool emitted = false;
          story.updates.listen((_) => emitted = true);
          async.flushMicrotasks();

          story.updateStoryData(newDto);
          async.flushMicrotasks();

          expect(emitted, isTrue);
        });
      });

      test('AND id does not match THEN no emit', () {
        fakeAsync((async) {
          final newDto = StoryAPIDataDto(
            id: 2,
            storyData: StoryDataDto(id: 2, slidesCount: 1),
            hasAudio: false,
            title: 'title',
            titleColor: '#000000',
            backgroundColor: '#FFFFFF',
            opened: false,
            aspectRatio: 1.0,
          );

          bool emitted = false;
          story.updates.listen((_) => emitted = true);
          async.flushMicrotasks();

          story.updateStoryData(newDto);
          async.elapse(const Duration(seconds: 1));

          expect(emitted, isFalse);
        });
      });

      test('AND no listener THEN no emit', () {
        final newDto = StoryAPIDataDto(
          id: 1,
          storyData: StoryDataDto(id: 1, slidesCount: 1),
          hasAudio: true,
          title: 'title',
          titleColor: '#000000',
          backgroundColor: '#FFFFFF',
          opened: true,
          aspectRatio: 1.0,
        );

        story.updateStoryData(newDto);
        expect(story.controller.hasListener, isFalse);
      });
    });
  });
}
