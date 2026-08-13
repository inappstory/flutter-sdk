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
  });
}
