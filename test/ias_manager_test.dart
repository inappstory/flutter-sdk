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

    group('WHEN showing a story with tags', () {
      test('THEN it forwards tags to the existing native API', () async {
        Object? message;
        const channel =
            'dev.flutter.pigeon.inappstory_plugin.IASSingleStoryHostApi.show';
        messenger.setMockMessageHandler(channel, (data) async {
          message = codec.decodeMessage(data);
          return codec.encodeMessage(<Object?>[]);
        });
        addTearDown(() => messenger.setMockMessageHandler(channel, null));

        final operation = manager.showStory('story-id', tags: const ['promo']);

        expect(await operation.value, isTrue);
        final arguments = message! as List<Object?>;
        expect(arguments[0], 'story-id');
        expect(arguments[2], ['promo']);
      });

      test('THEN it preserves the old call when tags are omitted', () async {
        Object? message;
        const channel =
            'dev.flutter.pigeon.inappstory_plugin.IASSingleStoryHostApi.show';
        messenger.setMockMessageHandler(channel, (data) async {
          message = codec.decodeMessage(data);
          return codec.encodeMessage(<Object?>[]);
        });
        addTearDown(() => messenger.setMockMessageHandler(channel, null));

        final operation = manager.showStory('story-id');

        expect(await operation.value, isTrue);
        expect((message! as List<Object?>)[2], isNull);
      });
    });

    group('WHEN showing an in-app message by ID with tags', () {
      test('THEN it forwards tags to the existing native API', () async {
        Object? message;
        const channel =
            'dev.flutter.pigeon.inappstory_plugin.IASInAppMessagesHostApi.showById';
        messenger.setMockMessageHandler(channel, (data) async {
          message = codec.decodeMessage(data);
          return codec.encodeMessage(<Object?>[]);
        });
        addTearDown(() => messenger.setMockMessageHandler(channel, null));

        final operation = manager.showIAMById(
          'message-id',
          tags: const ['promo'],
        );

        expect(await operation.value, isTrue);
        final arguments = message! as List<Object?>;
        expect(arguments[0], 'message-id');
        expect(arguments[4], ['promo']);
      });
    });

    group('WHEN showing an in-app message by event with tags', () {
      test('THEN it forwards tags to the existing native API', () async {
        Object? message;
        const channel =
            'dev.flutter.pigeon.inappstory_plugin.IASInAppMessagesHostApi.showByEvent';
        messenger.setMockMessageHandler(channel, (data) async {
          message = codec.decodeMessage(data);
          return codec.encodeMessage(<Object?>[]);
        });
        addTearDown(() => messenger.setMockMessageHandler(channel, null));

        final operation = manager.showIAMByEvent(
          'welcome',
          tags: const ['promo'],
        );

        expect(await operation.value, isTrue);
        final arguments = message! as List<Object?>;
        expect(arguments[0], 'welcome');
        expect(arguments[4], ['promo']);
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
