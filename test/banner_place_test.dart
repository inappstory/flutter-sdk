import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/generated/banner_place_generated.g.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  group('$BannerPlace', () {
    late List<Map<String, dynamic>> binaryMessengerCalls;

    setUp(() {
      binaryMessengerCalls = [];
      final codec = BannerViewHostApi.pigeonChannelCodec;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerViewHostApi.changeBannerPlaceId',
          codec,
        ),
        (message) async => <Object?>[null],
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerViewHostApi.deInitBannerPlace',
          codec,
        ),
        (message) async => <Object?>[null],
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerViewHostApi.setInteraction',
          codec,
        ),
        (message) async {
          final args = message as List<Object?>;
          binaryMessengerCalls.add({
            'channel': 'setInteraction',
            'isInteractionEnabled': args[0],
          });
          return <Object?>[null];
        },
      );
    });

    tearDown(() {
      final codec = BannerViewHostApi.pigeonChannelCodec;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerViewHostApi.changeBannerPlaceId',
          codec,
        ),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerViewHostApi.deInitBannerPlace',
          codec,
        ),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerViewHostApi.setInteraction',
          codec,
        ),
        null,
      );
    });

    group('GIVEN a BannerPlace widget', () {
      testWidgets('WHEN built with default settings THEN it renders without error', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'test_place',
                height: 140,
                autoLoad: false,
              ),
            ),
          ),
        );

        expect(find.byType(BannerPlace), findsOneWidget);
      });

      testWidgets('WHEN a modal bottom sheet is pushed on top THEN interaction is disabled', (tester) async {
        late BuildContext savedContext;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  savedContext = context;
                  return const BannerPlace(
                    placeId: 'test_place',
                    height: 140,
                    autoLoad: false,
                  );
                },
              ),
            ),
          ),
        );

        // Open modal bottom sheet
        showModalBottomSheet<void>(
          context: savedContext,
          builder: (_) => const SizedBox(height: 200, child: Text('Modal Content')),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Modal Content'), findsOneWidget);

        // Pop modal bottom sheet
        Navigator.of(savedContext).pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Modal Content'), findsNothing);
      });

      testWidgets('WHEN isInteractionEnabled is updated THEN widget syncs interaction', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'test_place',
                height: 140,
                autoLoad: false,
                isInteractionEnabled: true,
              ),
            ),
          ),
        );

        expect(find.byType(BannerPlace), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'test_place',
                height: 140,
                autoLoad: false,
                isInteractionEnabled: false,
              ),
            ),
          ),
        );

        expect(find.byType(BannerPlace), findsOneWidget);
      });

      testWidgets(
          'WHEN built with bannerPlaceLoaderBuilder THEN loader is displayed initially',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'test_place',
                height: 140,
                autoLoad: false,
                bannerPlaceLoaderBuilder: _testLoaderBuilder,
              ),
            ),
          ),
        );

        expect(find.text('Banner Loader'), findsOneWidget);
      });

      testWidgets(
          'WHEN timeout expires THEN onBannerPlaceLoadError is called and errorBuilder is shown',
          (tester) async {
        String? reportedError;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'test_place',
                height: 140,
                autoLoad: false,
                loadingTimeout: const Duration(milliseconds: 100),
                onBannerPlaceLoadError: (error) {
                  reportedError = error;
                },
                bannerPlaceErrorBuilder: (context, error) =>
                    Text('Error: $error'),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 150));

        expect(reportedError, 'Banner loading timed out');
        expect(find.text('Error: Banner loading timed out'), findsOneWidget);
      });

      testWidgets(
          'WHEN hideOnEmpty is true and error occurs with no errorBuilder THEN it shrinks',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'test_place',
                height: 140,
                autoLoad: false,
                hideOnEmpty: true,
                loadingTimeout: const Duration(milliseconds: 50),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        final sizedBox = tester.widget<SizedBox>(
          find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == 0.0 && w.height == 0.0,
          ),
        );
        expect(sizedBox, isNotNull);
      });

      testWidgets(
          'WHEN native calls onBannerPlaceLoadError THEN onBannerPlaceLoadError is invoked and errorBuilder renders',
          (tester) async {
        String? receivedError;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'test_place',
                height: 140,
                autoLoad: false,
                onBannerPlaceLoadError: (msg) {
                  receivedError = msg;
                },
                bannerPlaceErrorBuilder: (context, error) =>
                    Text('Failed: $error'),
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
        final encoded = codec.encodeMessage(<Object?>['Network connection failed']);
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(channelName, encoded, (reply) {});
        await tester.pump();

        expect(receivedError, 'Network connection failed');
        expect(find.text('Failed: Network connection failed'), findsOneWidget);
      });

      testWidgets(
          'WHEN native calls onBannerPlaceLoaded with size == 0 and hideOnEmpty is true THEN it shrinks',
          (tester) async {
        int? reportedSize;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'test_place',
                height: 140,
                autoLoad: false,
                hideOnEmpty: true,
                onBannerPlaceLoaded: (size, height) {
                  reportedSize = size;
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
        final encoded = codec.encodeMessage(<Object?>[0, 0]);
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(channelName, encoded, (reply) {});
        await tester.pump();

        expect(reportedSize, 0);
        final sizedBox = tester.widget<SizedBox>(
          find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == 0.0 && w.height == 0.0,
          ),
        );
        expect(sizedBox, isNotNull);
      });

      testWidgets(
          'WHEN native calls onBannerPlaceLoaded with size > 0 THEN loader fades out and callback is invoked',
          (tester) async {
        int? reportedSize;
        int? reportedHeight;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'test_place',
                height: 140,
                autoLoad: false,
                bannerPlaceLoaderBuilder: _testLoaderBuilder,
                onBannerPlaceLoaded: (size, height) {
                  reportedSize = size;
                  reportedHeight = height;
                },
              ),
            ),
          ),
        );

        // Initially loader is visible with opacity 1.0
        final initialOpacityFinder = find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.text('Banner Loader'),
        );
        expect(initialOpacityFinder, findsOneWidget);

        final animatedOpacityBefore = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(animatedOpacityBefore.opacity, 1.0);

        final detector = tester.widget<VisibilityDetector>(
          find.byType(VisibilityDetector),
        );
        final bannerWidgetId = (detector.key as ValueKey<String>).value;
        final codec = BannerPlaceCallbackFlutterApi.pigeonChannelCodec;

        final channelName =
            'dev.flutter.pigeon.inappstory_plugin.BannerPlaceCallbackFlutterApi.onBannerPlaceLoaded.$bannerWidgetId';
        final encoded = codec.encodeMessage(<Object?>[3, 140]);
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(channelName, encoded, (reply) {});
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(reportedSize, 3);
        expect(reportedHeight, 140);

        final animatedOpacityAfter = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(animatedOpacityAfter.opacity, 0.0);
      });

      testWidgets(
          'WHEN placeId changes THEN changeBannerPlaceId is sent to native host',
          (tester) async {
        String? newPlaceIdReceived;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'initial_place',
                height: 140,
                autoLoad: false,
              ),
            ),
          ),
        );

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
            newPlaceIdReceived = args[0] as String?;
            return <Object?>[null];
          },
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'updated_place',
                height: 140,
                autoLoad: false,
              ),
            ),
          ),
        );

        expect(newPlaceIdReceived, 'updated_place');
      });

      testWidgets(
          'WHEN widget is disposed THEN deInitBannerPlace is called on native host',
          (tester) async {
        bool deInitCalled = false;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BannerPlace(
                placeId: 'test_place',
                height: 140,
                autoLoad: false,
              ),
            ),
          ),
        );

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

        // Replace with empty container to trigger dispose
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );

        expect(deInitCalled, isTrue);
      });
    });
  });
}

Widget _testLoaderBuilder(BuildContext context) =>
    const Center(child: Text('Banner Loader'));

