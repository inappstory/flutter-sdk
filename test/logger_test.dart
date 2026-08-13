import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/controllers/logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$IASLogger', () {
    late IASLogger logger;

    group('GIVEN logger', () {
      setUp(() {
        logger = IASLogger.create();
      });

      test('WHEN debugLog with null message THEN logStore remains empty', () {
        logger.debugLog('tag', null);
        expect(logger.logStore, isEmpty);
      });

      test('WHEN debugLog with empty string THEN logStore remains empty', () {
        logger.debugLog('tag', '');
        expect(logger.logStore, isEmpty);
      });

      test('WHEN debugLog with hello THEN logStore has one entry with hello', () {
        logger.debugLog('tag', 'hello');
        expect(logger.logStore, hasLength(1));
        expect(logger.logStore.first.values.first, 'hello');
      });

      test('WHEN errorLog with null message THEN logStore remains empty', () {
        logger.errorLog('tag', null);
        expect(logger.logStore, isEmpty);
      });

      test('WHEN errorLog with error! THEN logStore has one entry', () {
        logger.errorLog('tag', 'error!');
        expect(logger.logStore, hasLength(1));
        expect(logger.logStore.first.values.first, 'error!');
      });
    });

    group('GIVEN logger with onDebugLog callback', () {
      int callCount = 0;
      String? receivedTag;
      String? receivedMessage;

      setUp(() {
        callCount = 0;
        receivedTag = null;
        receivedMessage = null;
        logger = IASLogger.create(
          onDebugLog: (tag, message) {
            callCount++;
            receivedTag = tag;
            receivedMessage = message;
          },
        );
      });

      test('WHEN debugLog with empty or null message THEN callback is not called', () {
        logger.debugLog('tag', null);
        logger.debugLog('tag', '');
        expect(callCount, 0);
      });

      test('WHEN debugLog called THEN callback receives tag and message', () {
        logger.debugLog('myTag', 'myMessage');
        expect(receivedTag, 'myTag');
        expect(receivedMessage, 'myMessage');
      });
    });

    group('GIVEN logger with onErrorLog callback', () {
      String? receivedTag;
      String? receivedMessage;

      setUp(() {
        receivedTag = null;
        receivedMessage = null;
        logger = IASLogger.create(
          onErrorLog: (tag, message) {
            receivedTag = tag;
            receivedMessage = message;
          },
        );
      });

      test('WHEN errorLog called THEN callback receives tag and message', () {
        logger.errorLog('errTag', 'errMessage');
        expect(receivedTag, 'errTag');
        expect(receivedMessage, 'errMessage');
      });
    });
  });
}
