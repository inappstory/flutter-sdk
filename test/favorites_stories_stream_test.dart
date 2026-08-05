// ignore_for_file: invalid_use_of_protected_member
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/generated/pigeon_generated.g.dart'
    show StoryAPIDataDto, StoryDataDto, StoryFavoriteItemAPIDataDto;
import 'package:inappstory_plugin/src/widgets/builders/base_story_builder.dart';
import 'package:inappstory_plugin/src/widgets/streams/favorites_stories_stream.dart';

StoryAPIDataDto storyDto(int id) => StoryAPIDataDto(
      id: id,
      storyData: StoryDataDto(id: id, slidesCount: 1),
      hasAudio: false,
      title: 't$id',
      titleColor: '#000000',
      backgroundColor: '#FFFFFF',
      opened: false,
      aspectRatio: 1.0,
    );

StoryFavoriteItemAPIDataDto favDto(int id) =>
    StoryFavoriteItemAPIDataDto(id: id, backgroundColor: '#000000');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Direct calls to the overridden dispatch methods exercise the favorites
  // logic without listen() (which would reach the native SDK).
  FavoritesStoriesStream build({
    void Function(int size, String feed)? onLoaded,
    void Function(String? reason)? onError,
  }) =>
      FavoritesStoriesStream(
        feed: 'feedA',
        storyWidgetBuilder: (story, decorator) =>
            BaseStoryBuilder(story, decorator: decorator),
        onStoriesLoaded: onLoaded,
        onStoriesLoadError: onError,
      );

  List<int> idsOf(FavoritesStoriesStream s) =>
      s.stories.map((e) => e.dto.id).toList();

  group('$FavoritesStoriesStream', () {
    late FavoritesStoriesStream stream;
    setUp(() => stream = build());

    group('WHEN updateStoriesData is called', () {
      test('THEN stories and tempStories are populated', () {
        stream.updateStoriesData([storyDto(1), storyDto(2)]);

        expect(idsOf(stream), [1, 2]);
        expect(stream.tempStories.map((e) => e.dto.id), [1, 2]);
      });

      test('THEN null entries are filtered out', () {
        stream.updateStoriesData([storyDto(1), null]);
        expect(idsOf(stream), [1]);
      });
    });

    group('WHEN updateFavoriteStoriesData is called', () {
      test('AND the list is empty THEN stories are cleared', () {
        stream.updateStoriesData([storyDto(1)]);
        stream.updateFavoriteStoriesData([]);
        expect(stream.stories, isEmpty);
      });

      test('AND a favorite matches a current story THEN it is kept', () {
        stream.updateStoriesData([storyDto(1), storyDto(2)]);
        stream.updateFavoriteStoriesData([favDto(1)]);
        expect(idsOf(stream), [1]);
      });

      test('AND a favorite is only in tempStories THEN it is restored', () {
        stream.updateStoriesData([storyDto(1), storyDto(2)]);
        stream.updateFavoriteStoriesData([favDto(1)]); // stories -> [1]
        stream.updateFavoriteStoriesData([favDto(2)]); // 2 only in tempStories
        expect(idsOf(stream), [2]);
      });

      test('AND a favorite matches nothing THEN it is skipped', () {
        stream.updateStoriesData([storyDto(1)]);
        stream.updateFavoriteStoriesData([favDto(99)]);
        expect(stream.stories, isEmpty);
      });
    });

    group('WHEN updateStoryData is called', () {
      test('AND no story matches THEN it does not throw', () {
        stream.updateStoriesData([storyDto(1)]);
        expect(() => stream.updateStoryData(storyDto(2)), returnsNormally);
      });
    });

    group('WHEN storiesLoaded is dispatched', () {
      test('THEN the onStoriesLoaded callback fires', () {
        final sizes = <int>[];
        stream = build(onLoaded: (size, feed) => sizes.add(size));
        stream.storiesLoaded(5, 'feedA');
        expect(sizes, [5]);
      });
    });

    group('WHEN storiesUpdateFailure is dispatched', () {
      test('AND the feed matches THEN onStoriesLoadError fires', () {
        final errors = <String?>[];
        stream = build(onError: errors.add);
        stream.storiesUpdateFailure('feedA', 'boom');
        expect(errors, ['boom']);
      });

      test('AND the feed differs THEN it is ignored', () {
        final errors = <String?>[];
        stream = build(onError: errors.add);
        stream.storiesUpdateFailure('otherFeed', 'boom');
        expect(errors, isEmpty);
      });
    });
  });
}
