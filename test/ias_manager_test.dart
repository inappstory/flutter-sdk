import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/callbacks/ias_error_callback_impl.dart';
import 'package:inappstory_plugin/src/controllers/ias_manager.dart';
import 'package:inappstory_plugin/src/controllers/logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // InAppStoryManager is a singleton whose methods mostly delegate to native
  // host APIs; only its pure surface is unit-testable here.
  final manager = InAppStoryManager.instance;

  group('$InAppStoryManager', () {
    const codec = StandardMessageCodec();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    List<List<Object?>> captureStoryCalls(String method) {
      final channel =
          'dev.flutter.pigeon.inappstory_plugin.IASSingleStoryHostApi.$method';
      final calls = <List<Object?>>[];
      messenger.setMockMessageHandler(channel, (data) async {
        calls.add(codec.decodeMessage(data)! as List<Object?>);
        return codec.encodeMessage(<Object?>[]);
      });
      addTearDown(() => messenger.setMockMessageHandler(channel, null));
      return calls;
    }

    List<List<Object?>> captureIAMCalls(String method) {
      final channel =
          'dev.flutter.pigeon.inappstory_plugin.IASInAppMessagesHostApi.$method';
      final calls = <List<Object?>>[];
      messenger.setMockMessageHandler(channel, (data) async {
        calls.add(codec.decodeMessage(data)! as List<Object?>);
        return codec.encodeMessage(<Object?>[]);
      });
      addTearDown(() => messenger.setMockMessageHandler(channel, null));
      return calls;
    }

    group('GIVEN the logger', () {
      test('WHEN unset THEN a logger is created', () {
        expect(manager.logger, isA<IASLogger>());
      });

      test('WHEN set THEN the same logger is returned', () {
        final logger = IASLogger.create();
        manager.logger = logger;
        expect(manager.logger, same(logger));
      });
    });

    group('WHEN setLocale has no country code', () {
      test('THEN it skips the native call (null country)', () {
        expect(manager.setLocale(const Locale('en')), completes);
      });

      test('THEN it skips the native call (empty country)', () {
        expect(manager.setLocale(const Locale('en', '')), completes);
      });
    });

    group('WHEN registering callbacks', () {
      test('THEN it does not throw', () {
        expect(() {
          void cb(slideData, url, clickAction) {}
          manager.addCallToActionCallback(cb);
          manager.removeCallToActionCallback(cb);
          manager.setErrorCallback(const IASErrorCallback());
        }, returnsNormally);
      });
    });

    group('WHEN showing a story', () {
      test('THEN it calls the native show API without targeting tags',
          () async {
        final calls = captureStoryCalls('show');

        final operation = manager.showStory('story-id');

        expect(await operation.value, isTrue);
        expect(calls, [
          ['story-id', isA<String>()],
        ]);
      });
    });

    group('WHEN showing a story with targeting', () {
      test('THEN it forwards the tags to the native targeting API', () async {
        final calls = captureStoryCalls('showWithTargeting');

        final operation = manager.showStoryWithTargeting(
          'story-id',
          tags: const ['promo'],
        );

        expect(await operation.value, isTrue);
        expect(calls, [
          [
            'story-id',
            isA<String>(),
            ['promo'],
          ],
        ]);
      });

      test('THEN it sends no tags when they are omitted', () async {
        final calls = captureStoryCalls('showWithTargeting');

        final operation = manager.showStoryWithTargeting('story-id');

        expect(await operation.value, isTrue);
        expect(calls, [
          ['story-id', isA<String>(), null],
        ]);
      });

      test('THEN it replaces invalid tags with an empty list', () async {
        final calls = captureStoryCalls('showWithTargeting');

        final operation = manager.showStoryWithTargeting(
          'story-id',
          tags: const ['not valid'],
        );

        expect(await operation.value, isTrue);
        expect(calls, [
          ['story-id', isA<String>(), <String>[]],
        ]);
      });
    });

    group('WHEN showing an in-app message by ID', () {
      test('THEN it calls the native API without targeting tags', () async {
        final calls = captureIAMCalls('showById');

        final operation = manager.showIAMById('message-id');

        expect(await operation.value, isTrue);
        expect(calls, [
          ['message-id', isA<String>(), false, null],
        ]);
      });

      test('THEN the targeting method forwards tags', () async {
        final calls = captureIAMCalls('showByIdWithTargeting');

        final operation = manager.showIAMByIdWithTargeting(
          'message-id',
          tags: const ['promo'],
        );

        expect(await operation.value, isTrue);
        expect(calls, [
          [
            'message-id',
            isA<String>(),
            false,
            null,
            ['promo']
          ],
        ]);
      });

      test('THEN the targeting method sends null when tags are omitted',
          () async {
        final calls = captureIAMCalls('showByIdWithTargeting');

        final operation = manager.showIAMByIdWithTargeting('message-id');

        expect(await operation.value, isTrue);
        expect(calls, [
          ['message-id', isA<String>(), false, null, null],
        ]);
      });

      test('THEN the targeting method replaces invalid tags with an empty list',
          () async {
        final calls = captureIAMCalls('showByIdWithTargeting');

        final operation = manager.showIAMByIdWithTargeting(
          'message-id',
          tags: const ['not valid'],
        );

        expect(await operation.value, isTrue);
        expect(calls, [
          ['message-id', isA<String>(), false, null, <String>[]],
        ]);
      });
    });

    group('WHEN showing an in-app message by event', () {
      test('THEN it calls the native API without tags', () async {
        final calls = captureIAMCalls('showByEvent');

        final operation = manager.showIAMByEvent('welcome');

        expect(await operation.value, isTrue);
        expect(calls, [
          ['welcome', isA<String>(), false, null],
        ]);
      });

      test('THEN the targeting method forwards tags', () async {
        final calls = captureIAMCalls('showByEventWithTargeting');

        final operation = manager.showIAMByEventWithTargeting(
          'welcome',
          tags: const ['promo'],
        );

        expect(await operation.value, isTrue);
        expect(calls, [
          [
            'welcome',
            isA<String>(),
            false,
            null,
            ['promo']
          ],
        ]);
      });
    });

    group('WHEN controlling games', () {
      const gamesApi = 'dev.flutter.pigeon.inappstory_plugin.IASGamesHostApi';

      List<Object?> captureCalls(String method) {
        final calls = <Object?>[];
        final channel = '$gamesApi.$method';
        messenger.setMockMessageHandler(channel, (data) async {
          calls.add(codec.decodeMessage(data));
          return codec.encodeMessage(<Object?>[]);
        });
        addTearDown(() => messenger.setMockMessageHandler(channel, null));
        return calls;
      }

      test('THEN openGame forwards the game id to native', () async {
        final calls = captureCalls('openGame');

        await manager.openGame('maestro');

        expect(calls, [
          ['maestro'],
        ]);
      });

      test('THEN closeGame calls native', () async {
        final calls = captureCalls('closeGame');

        await manager.closeGame();

        expect(calls, hasLength(1));
      });

      test('THEN preloadGames calls native', () async {
        final calls = captureCalls('preloadGames');

        await manager.preloadGames();

        expect(calls, hasLength(1));
      });
    });
  });
}
