import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/generated/banner_place_generated.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$BannerPlaceManager', () {
    late List<Map<String, dynamic>> binaryMessengerCalls;

    setUp(() {
      binaryMessengerCalls = [];
      final codec = BannerPlaceManagerHostApi.pigeonChannelCodec;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceManagerHostApi.setInteraction',
          codec,
        ),
        (message) async {
          final args = message as List<Object?>;
          binaryMessengerCalls.add({
            'channel': 'setInteraction',
            'placeId': args[0],
            'isInteractionEnabled': args[1],
          });
          return <Object?>[null];
        },
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceManagerHostApi.loadBannerPlace',
          codec,
        ),
        (message) async {
          final args = message as List<Object?>;
          binaryMessengerCalls.add({
            'channel': 'loadBannerPlace',
            'placeId': args[0],
          });
          return <Object?>[null];
        },
      );
    });

    tearDown(() {
      final codec = BannerPlaceManagerHostApi.pigeonChannelCodec;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceManagerHostApi.setInteraction',
          codec,
        ),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.inappstory_plugin.BannerPlaceManagerHostApi.loadBannerPlace',
          codec,
        ),
        null,
      );
    });

    group('GIVEN a BannerPlaceManager instance', () {
      test('WHEN setInteraction is called with false THEN it sends message to host api', () async {
        await BannerPlaceManager.instance.setInteraction(
          placeId: 'test_place',
          isInteractionEnabled: false,
        );

        expect(binaryMessengerCalls.length, 1);
        expect(binaryMessengerCalls.first, {
          'channel': 'setInteraction',
          'placeId': 'test_place',
          'isInteractionEnabled': false,
        });
      });

      test('WHEN setInteraction is called with true THEN it sends message to host api', () async {
        await BannerPlaceManager.instance.setInteraction(
          placeId: 'test_place',
          isInteractionEnabled: true,
        );

        expect(binaryMessengerCalls.length, 1);
        expect(binaryMessengerCalls.first, {
          'channel': 'setInteraction',
          'placeId': 'test_place',
          'isInteractionEnabled': true,
        });
      });

      test('WHEN load is called THEN it sends load message to host api', () async {
        await BannerPlaceManager.instance.load('test_place');

        expect(binaryMessengerCalls.length, 1);
        expect(binaryMessengerCalls.first, {
          'channel': 'loadBannerPlace',
          'placeId': 'test_place',
        });
      });
    });
  });
}
