import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/callbacks/ias_error_callback_impl.dart';

void main() {
  group('$ErrorCallbackFlutterApiImpl', () {
    group('GIVEN no callback set', () {
      late ErrorCallbackFlutterApiImpl impl;
      setUp(() {
        impl = ErrorCallbackFlutterApiImpl();
      });

      test('WHEN sessionError called THEN does not throw', () {
        expect(() => impl.sessionError(), returnsNormally);
      });

      test('WHEN noConnection called THEN does not throw', () {
        expect(() => impl.noConnection(), returnsNormally);
      });
    });

    group('GIVEN callback set', () {
      late ErrorCallbackFlutterApiImpl impl;
      late bool sessionErrorCalled;
      late bool noConnectionCalled;

      setUp(() {
        impl = ErrorCallbackFlutterApiImpl();
        sessionErrorCalled = false;
        noConnectionCalled = false;
        impl.callback = IASErrorCallback(
          sessionError: () => sessionErrorCalled = true,
          noConnection: () => noConnectionCalled = true,
        );
      });

      test('WHEN sessionError called THEN sessionError function fires', () {
        impl.sessionError();
        expect(sessionErrorCalled, isTrue);
      });

      test('WHEN noConnection called THEN noConnection function fires', () {
        impl.noConnection();
        expect(noConnectionCalled, isTrue);
      });
    });

    group('GIVEN callback with only sessionError', () {
      late ErrorCallbackFlutterApiImpl impl;
      setUp(() {
        impl = ErrorCallbackFlutterApiImpl();
        impl.callback = IASErrorCallback(
          sessionError: () {},
        );
      });

      test('WHEN noConnection called THEN does not throw', () {
        expect(() => impl.noConnection(), returnsNormally);
      });
    });
  });
}
