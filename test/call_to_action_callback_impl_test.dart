import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/callbacks/call_to_action_callback_impl.dart';

void main() {
  group('$CallToActionCallbackImpl', () {
    group('GIVEN empty impl', () {
      late CallToActionCallbackImpl impl;

      setUp(() {
        impl = CallToActionCallbackImpl();
      });

      test('WHEN addCallback THEN the callback fires once', () {
        int callCount = 0;
        void myCallback(slideData, url, clickAction) => callCount++;

        impl.addCallback(myCallback);
        impl.callToAction(null, 'https://example.com', null);

        expect(callCount, 1);
      });

      test('WHEN removeCallback THEN does not throw', () {
        expect(() => impl.removeCallback((_, __, ___) {}), returnsNormally);
      });

      test('WHEN callToAction THEN does not throw', () {
        expect(() => impl.callToAction(null, 'https://example.com', null), returnsNormally);
      });
    });

    group('GIVEN callback registered', () {
      late CallToActionCallbackImpl impl;
      late int callCount;
      late void Function(dynamic, String?, dynamic) myCallback;

      setUp(() {
        impl = CallToActionCallbackImpl();
        callCount = 0;
        myCallback = (slideData, url, clickAction) {
          callCount++;
        };
        impl.addCallback(myCallback);
      });

      test('WHEN addCallback same callback again THEN still one entry (duplicate ignored)', () {
        impl.addCallback(myCallback);
        impl.callToAction(null, 'https://example.com', null);
        expect(callCount, 1);
      });

      test('WHEN removeCallback THEN callbacks list is empty', () {
        impl.removeCallback(myCallback);
        impl.callToAction(null, 'https://example.com', null);
        expect(callCount, 0);
      });
    });

    group('GIVEN two callbacks registered', () {
      late CallToActionCallbackImpl impl;
      late List<String?> urlsReceived;

      setUp(() {
        impl = CallToActionCallbackImpl();
        urlsReceived = [];
        impl.addCallback((slideData, url, clickAction) => urlsReceived.add(url));
        impl.addCallback((slideData, url, clickAction) => urlsReceived.add('$url-2'));
      });

      test('WHEN callToAction THEN both callbacks receive the arguments', () {
        impl.callToAction(null, 'https://example.com', null);
        expect(urlsReceived, ['https://example.com', 'https://example.com-2']);
      });
    });
  });
}
