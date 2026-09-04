import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/generated/banner_place_generated.g.dart';
import 'package:integration_test/integration_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

Future<void> _sendPlatformMessage(
  String channelName,
  List<Object?> message,
  MessageCodec<Object?> codec,
) async {
  final encoded = codec.encodeMessage(message);
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(channelName, encoded, (reply) {});
}

  group('BannerPlace Integration (Flutter ↔ Pigeon ↔ Native)', () {
    testWidgets('GIVEN BannerPlace mounted WHEN initialized THEN platform view renders and loader shows',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'integration_test_place',
              height: 140,
              autoLoad: false,
              bannerPlaceLoaderBuilder: (context) =>
                  const Center(child: Text('Integration Banner Loader')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BannerPlace), findsOneWidget);
      expect(find.text('Integration Banner Loader'), findsOneWidget);
    });

    testWidgets('GIVEN BannerPlace WHEN loadingTimeout expires THEN onBannerPlaceLoadError is invoked and errorBuilder renders',
        (WidgetTester tester) async {
      String? errorMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'timeout_test_place',
              height: 140,
              autoLoad: false,
              loadingTimeout: const Duration(milliseconds: 100),
              onBannerPlaceLoadError: (msg) {
                errorMessage = msg;
              },
              bannerPlaceErrorBuilder: (context, error) =>
                  Text('Banner Error: $error'),
            ),
          ),
        ),
      );

      // Wait for the fallback timer to expire
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(errorMessage, 'Banner loading timed out');
      expect(find.text('Banner Error: Banner loading timed out'), findsOneWidget);
    });

    testWidgets('GIVEN BannerPlace with hideOnEmpty WHEN loading times out THEN it collapses to shrink size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'timeout_shrink_place',
              height: 140,
              autoLoad: false,
              hideOnEmpty: true,
              loadingTimeout: Duration(milliseconds: 50),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 0.0 && w.height == 0.0,
        ),
      );
      expect(sizedBox, isNotNull);
    });

    testWidgets('GIVEN BannerPlace WHEN native sends onBannerPlaceLoadError THEN onBannerPlaceLoadError fires',
        (WidgetTester tester) async {
      String? receivedError;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'native_error_place',
              height: 140,
              autoLoad: false,
              onBannerPlaceLoadError: (msg) {
                receivedError = msg;
              },
              bannerPlaceErrorBuilder: (context, err) =>
                  Text('Native Failure: $err'),
            ),
          ),
        ),
      );

      final detector = tester.widget<VisibilityDetector>(
        find.byType(VisibilityDetector),
      );
      final bannerWidgetId = (detector.key as ValueKey<String>).value;
      final codec = BannerPlaceCallbackFlutterApi.pigeonChannelCodec;

      final channelName =
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceCallbackFlutterApi.onBannerPlaceLoadError.$bannerWidgetId';
      await _sendPlatformMessage(
        channelName,
        <Object?>['Banners failed from native SDK'],
        codec,
      );
      await tester.pumpAndSettle();

      expect(receivedError, 'Banners failed from native SDK');
      expect(find.text('Native Failure: Banners failed from native SDK'), findsOneWidget);
    });

    testWidgets('GIVEN BannerPlace with hideOnEmpty WHEN native sends onBannerPlaceLoaded with size 0 THEN widget shrinks',
        (WidgetTester tester) async {
      int? receivedSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'empty_banner_place',
              height: 140,
              autoLoad: false,
              hideOnEmpty: true,
              onBannerPlaceLoaded: (size, height) {
                receivedSize = size;
              },
            ),
          ),
        ),
      );

      final detector = tester.widget<VisibilityDetector>(
        find.byType(VisibilityDetector),
      );
      final bannerWidgetId = (detector.key as ValueKey<String>).value;
      final codec = BannerPlaceCallbackFlutterApi.pigeonChannelCodec;

      final channelName =
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceCallbackFlutterApi.onBannerPlaceLoaded.$bannerWidgetId';
      await _sendPlatformMessage(channelName, <Object?>[0, 0], codec);
      await tester.pumpAndSettle();

      expect(receivedSize, 0);
      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 0.0 && w.height == 0.0,
        ),
      );
      expect(sizedBox, isNotNull);
    });

    testWidgets('GIVEN BannerPlace WHEN native sends onBannerPlaceLoaded with content THEN loader fades out and callback receives size',
        (WidgetTester tester) async {
      int? loadedSize;
      int? loadedHeight;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'content_banner_place',
              height: 140,
              autoLoad: false,
              bannerPlaceLoaderBuilder: (context) =>
                  const Center(child: Text('Loading Placeholder...')),
              onBannerPlaceLoaded: (size, height) {
                loadedSize = size;
                loadedHeight = height;
              },
            ),
          ),
        ),
      );

      // Verify loader opacity is 1.0 initially
      var animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, 1.0);

      final detector = tester.widget<VisibilityDetector>(
        find.byType(VisibilityDetector),
      );
      final bannerWidgetId = (detector.key as ValueKey<String>).value;
      final codec = BannerPlaceCallbackFlutterApi.pigeonChannelCodec;

      final channelName =
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceCallbackFlutterApi.onBannerPlaceLoaded.$bannerWidgetId';
      await _sendPlatformMessage(channelName, <Object?>[5, 140], codec);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(loadedSize, 5);
      expect(loadedHeight, 140);

      animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, 0.0);
    });

    testWidgets('GIVEN BannerPlace WHEN native sends onBannerScroll THEN onBannerScroll fires with index',
        (WidgetTester tester) async {
      int? scrolledIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'scroll_banner_place',
              height: 140,
              autoLoad: false,
              onBannerScroll: (index) {
                scrolledIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final detector = tester.widget<VisibilityDetector>(
        find.byType(VisibilityDetector),
      );
      final bannerWidgetId = (detector.key as ValueKey<String>).value;
      final codec = BannerPlaceCallbackFlutterApi.pigeonChannelCodec;

      final channelName =
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceCallbackFlutterApi.onBannerScroll.$bannerWidgetId';
      await _sendPlatformMessage(channelName, <Object?>[2], codec);
      await tester.pump();

      expect(scrolledIndex, 2);
    });

    testWidgets('GIVEN BannerPlace WHEN native sends onActionWith THEN onActionWith callback fires',
        (WidgetTester tester) async {
      BannerData? actionBannerData;
      String? actionEventName;
      Map<String, Object?>? actionData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'action_banner_place',
              height: 140,
              autoLoad: false,
              onActionWith: (bannerData, eventName, data) {
                actionBannerData = bannerData;
                actionEventName = eventName;
                actionData = data;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final detector = tester.widget<VisibilityDetector>(
        find.byType(VisibilityDetector),
      );
      final bannerWidgetId = (detector.key as ValueKey<String>).value;
      final codec = BannerPlaceCallbackFlutterApi.pigeonChannelCodec;

      final testBannerData = BannerData(
        id: 'banner_123',
        bannerPlace: 'action_banner_place',
        payload: 'test_payload',
      );

      final channelName =
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceCallbackFlutterApi.onActionWith.$bannerWidgetId';
      await _sendPlatformMessage(
        channelName,
        <Object?>[
          testBannerData,
          'BANNER_CLICK',
          <String, Object?>{'key': 'value'},
        ],
        codec,
      );
      await tester.pump();

      expect(actionBannerData?.id, 'banner_123');
      expect(actionBannerData?.bannerPlace, 'action_banner_place');
      expect(actionEventName, 'BANNER_CLICK');
      expect(actionData?['key'], 'value');
    });

    testWidgets('GIVEN BannerPlace WHEN placeId changes THEN changeBannerPlaceId host call is sent',
        (WidgetTester tester) async {
      String? capturedNewPlaceId;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'place_v1',
              height: 140,
              autoLoad: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final detector = tester.widget<VisibilityDetector>(
        find.byType(VisibilityDetector),
      );
      final bannerWidgetId = (detector.key as ValueKey<String>).value;
      final hostCodec = BannerViewHostApi.pigeonChannelCodec;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerViewHostApi.changeBannerPlaceId.$bannerWidgetId',
          hostCodec,
        ),
        (message) async {
          final args = message as List<Object?>;
          capturedNewPlaceId = args[0] as String?;
          return <Object?>[null];
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'place_v2',
              height: 140,
              autoLoad: false,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(capturedNewPlaceId, 'place_v2');
    });

    testWidgets('GIVEN BannerPlace WHEN disposed THEN deInitBannerPlace is invoked and channels cleaned up',
        (WidgetTester tester) async {
      bool deInitCalled = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BannerPlace(
              placeId: 'dispose_place',
              height: 140,
              autoLoad: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final detector = tester.widget<VisibilityDetector>(
        find.byType(VisibilityDetector),
      );
      final bannerWidgetId = (detector.key as ValueKey<String>).value;
      final hostCodec = BannerViewHostApi.pigeonChannelCodec;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerViewHostApi.deInitBannerPlace.$bannerWidgetId',
          hostCodec,
        ),
        (message) async {
          deInitCalled = true;
          return <Object?>[null];
        },
      );

      // Unmount the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(deInitCalled, isTrue);
    });

    testWidgets('GIVEN BannerPlaceManager WHEN host API methods called THEN Pigeon requests are dispatched',
        (WidgetTester tester) async {
      final List<String> dispatchedCalls = [];
      final managerCodec = BannerPlaceManagerHostApi.pigeonChannelCodec;
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

      final methods = [
        'loadBannerPlace',
        'reloadBannerPlace',
        'preloadBannerPlace',
        'pauseAutoscroll',
        'resumeAutoscroll',
        'showNext',
        'showPrevious',
      ];

      for (final method in methods) {
        messenger.setMockDecodedMessageHandler<Object?>(
          BasicMessageChannel<Object?>(
            'dev.flutter.pigeon.inappstory_plugin.BannerPlaceManagerHostApi.$method',
            managerCodec,
          ),
          (message) async {
            dispatchedCalls.add(method);
            return <Object?>[null];
          },
        );
      }

      messenger.setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceManagerHostApi.showByIndex',
          managerCodec,
        ),
        (message) async {
          dispatchedCalls.add('showByIndex');
          return <Object?>[null];
        },
      );

      messenger.setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceManagerHostApi.setInteraction',
          managerCodec,
        ),
        (message) async {
          dispatchedCalls.add('setInteraction');
          return <Object?>[null];
        },
      );

      final manager = BannerPlaceManager();
      await manager.loadBannerPlace('test_p');
      await manager.reloadBannerPlace('test_p');
      await manager.preloadBannerPlace('test_p');
      await manager.pauseAutoscroll('test_p');
      await manager.resumeAutoscroll('test_p');
      await manager.showNext('test_p');
      await manager.showPrevious('test_p');
      await manager.showByIndex('test_p', 1);
      await manager.setInteraction('test_p', true);

      expect(dispatchedCalls, [
        'loadBannerPlace',
        'reloadBannerPlace',
        'preloadBannerPlace',
        'pauseAutoscroll',
        'resumeAutoscroll',
        'showNext',
        'showPrevious',
        'showByIndex',
        'setInteraction',
      ]);
    });
  });
}
