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
    });
  });
}
