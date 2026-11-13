import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/generated/banner_place_generated.g.dart';
import 'package:inappstory_plugin/src/generated/pigeon_generated.g.dart'
    show InappstorySdkModuleHostApi;
import 'package:inappstory_plugin/src/helpers/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  group('$BannerList', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.InappstorySdkModuleHostApi.isInitialized',
          InappstorySdkModuleHostApi.pigeonChannelCodec,
        ),
        (message) async => <Object?>[true],
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerViewHostApi.deInitBannerPlace',
          BannerViewHostApi.pigeonChannelCodec,
        ),
        (message) async => <Object?>[null],
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.InappstorySdkModuleHostApi.isInitialized',
          InappstorySdkModuleHostApi.pigeonChannelCodec,
        ),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerViewHostApi.deInitBannerPlace',
          BannerViewHostApi.pigeonChannelCodec,
        ),
        null,
      );
    });

    testWidgets(
        'GIVEN a list with a viewport height WHEN built THEN it keeps that height',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BannerList(
              placeId: 'test_place',
              height: 240,
              autoLoad: false,
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(BannerList)).height, 240);
    });

    testWidgets(
        'GIVEN a list without a custom loader WHEN built THEN it shows no shimmer',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BannerList(
              placeId: 'test_place',
              height: 240,
              autoLoad: false,
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsNothing);
    });

    testWidgets(
        'GIVEN a list with the SDK placeholder WHEN built THEN it shows a shimmer',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerList(
              placeId: 'test_place',
              height: 240,
              autoLoad: false,
              bannerPlaceLoaderBuilder: (_) => const BannerListPlaceholder(),
            ),
          ),
        ),
      );

      expect(find.byType(BannerListPlaceholder), findsOneWidget);
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets(
        'GIVEN a list with a custom loader WHEN built THEN it uses that loader',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerList(
              placeId: 'test_place',
              height: 240,
              autoLoad: false,
              bannerPlaceLoaderBuilder: (_) => const Text('custom loader'),
            ),
          ),
        ),
      );

      expect(find.text('custom loader'), findsOneWidget);
      expect(find.byType(Shimmer), findsNothing);
    });
  });
}
