// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/controllers/feed_stories_controller.dart';

void main() {
  group('GIVEN a controller bound to a list', () {
    late FeedStoriesController controller;
    late List<String> reloaded;
    late FeedReloadCallback firstBinding;

    setUp(() {
      reloaded = <String>[];
      firstBinding = () async => reloaded.add('first');
      controller = FeedStoriesController()..attach(firstBinding);
    });

    test('WHEN fetching THEN the bound list reloads', () async {
      await controller.fetchFeedStories();

      expect(reloaded, ['first']);
    });

    group('WHEN the widget is disposed', () {
      setUp(() => controller.detach(firstBinding));

      test('THEN fetching reloads nothing', () async {
        await controller.fetchFeedStories();

        expect(reloaded, isEmpty);
      });
    });

    group('AND a new list bound its own reload', () {
      setUp(() => controller.attach(() async => reloaded.add('second')));

      group('WHEN the old widget is disposed afterwards', () {
        setUp(() => controller.detach(firstBinding));

        test('THEN the live binding survives', () async {
          await controller.fetchFeedStories();

          expect(reloaded, ['second']);
        });
      });
    });
  });
}
