// ignore_for_file: non_constant_identifier_names

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/controllers/appearance_manager.dart';
import 'package:inappstory_plugin/src/data/placeholder_decoration.dart';
import 'package:inappstory_plugin/src/generated/appearance_manager.g.dart';

class FakeAppearanceManagerHostApi implements AppearanceManagerHostApi {
  @override
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  String get pigeonVar_messageChannelSuffix => '';

  PlaceholderDecorationDto? lastStoriesPlaceholder;
  bool storiesPlaceholderCalled = false;

  PlaceholderDecorationDto? lastBannersPlaceholder;
  bool bannersPlaceholderCalled = false;

  @override
  Future<void> setStoriesPlaceholder(
      PlaceholderDecorationDto? decoration) async {
    storiesPlaceholderCalled = true;
    lastStoriesPlaceholder = decoration;
  }

  @override
  Future<void> setBannersPlaceholder(
      PlaceholderDecorationDto? decoration) async {
    bannersPlaceholderCalled = true;
    lastBannersPlaceholder = decoration;
  }

  @override
  Future<bool> getTimerGradientEnable() async => true;

  @override
  Future<void> setCloseIcon(String iconPath) async {}

  @override
  Future<void> setClosePosition(Position position) async {}

  @override
  Future<void> setCoverQuality(CoverQuality coverQuality) async {}

  @override
  Future<void> setDislikeIcon(String iconPath, String selectedIconPath) async {}

  @override
  Future<void> setFavoriteIcon(
      String iconPath, String selectedIconPath) async {}

  @override
  Future<void> setHasFavorites(bool value) async {}

  @override
  Future<void> setHasLike(bool value) async {}

  @override
  Future<void> setHasShare(bool value) async {}

  @override
  Future<void> setLikeIcon(String iconPath, String selectedIconPath) async {}

  @override
  Future<void> setNavBarColor(int color, int? darkColor) async {}

  @override
  Future<void> setReaderBackgroundColor(int color) async {}

  @override
  Future<void> setReaderCornerRadius(int radius) async {}

  @override
  Future<void> setReaderPresentationStyle(PresentationStyle style) async {}

  @override
  Future<void> setReaderScrollStyle(ScrollStyle style) async {}

  @override
  Future<void> setRefreshIcon(String iconPath) async {}

  @override
  Future<void> setShareIcon(String iconPath, String selectedIconPath) async {}

  @override
  Future<void> setSoundIcon(String iconPath, String selectedIconPath) async {}

  @override
  Future<void> setTimerGradient(
      {required List<int> colors, List<double> locations = const []}) async {}

  @override
  Future<void> setTimerGradientEnable(bool isEnabled) async {}

  @override
  Future<void> setUpGoods(GoodsItemAppearanceDto appearance) async {}
}

void main() {
  group('$AppearanceManager', () {
    late FakeAppearanceManagerHostApi fakeApi;
    late AppearanceManager manager;

    setUp(() {
      fakeApi = FakeAppearanceManagerHostApi();
      manager = AppearanceManager.forTesting(fakeApi);
    });

    group('WHEN setStoriesPlaceholder called with color and image', () {
      test('THEN passes dto with converted color and image', () async {
        await manager.setStoriesPlaceholder(
          color: const Color(0xFFFF0000),
          image: 'assets/story_loader.png',
        );

        expect(fakeApi.storiesPlaceholderCalled, isTrue);
        expect(fakeApi.lastStoriesPlaceholder?.color, 0xFFFF0000);
        expect(
            fakeApi.lastStoriesPlaceholder?.image, 'assets/story_loader.png');
      });
    });

    group('WHEN setStoriesPlaceholder called with decoration object', () {
      test('THEN passes dto from decoration', () async {
        await manager.setStoriesPlaceholder(
          decoration: const PlaceholderDecoration(
            color: Color(0xFF00FF00),
            image: 'assets/deco.png',
          ),
        );

        expect(fakeApi.storiesPlaceholderCalled, isTrue);
        expect(fakeApi.lastStoriesPlaceholder?.color, 0xFF00FF00);
        expect(fakeApi.lastStoriesPlaceholder?.image, 'assets/deco.png');
      });
    });

    group('WHEN setStoriesPlaceholder called with no arguments', () {
      test('THEN passes null dto to clear placeholder', () async {
        await manager.setStoriesPlaceholder();

        expect(fakeApi.storiesPlaceholderCalled, isTrue);
        expect(fakeApi.lastStoriesPlaceholder, isNull);
      });
    });

    group('WHEN setBannersPlaceholder called with color and image', () {
      test('THEN passes dto with converted color and image', () async {
        await manager.setBannersPlaceholder(
          color: const Color(0x33FFFFFF),
          image: 'assets/banner_loader.png',
        );

        expect(fakeApi.bannersPlaceholderCalled, isTrue);
        expect(fakeApi.lastBannersPlaceholder?.color, 0x33FFFFFF);
        expect(
            fakeApi.lastBannersPlaceholder?.image, 'assets/banner_loader.png');
      });
    });

    group('WHEN setBannersPlaceholder called with decoration object', () {
      test('THEN passes dto from decoration', () async {
        await manager.setBannersPlaceholder(
          decoration: const PlaceholderDecoration(color: Color(0xFF0000FF)),
        );

        expect(fakeApi.lastBannersPlaceholder?.color, 0xFF0000FF);
        expect(fakeApi.lastBannersPlaceholder?.image, isNull);
      });
    });

    group('WHEN setBannersPlaceholder called with no arguments', () {
      test('THEN passes null dto to clear placeholder', () async {
        await manager.setBannersPlaceholder();

        expect(fakeApi.bannersPlaceholderCalled, isTrue);
        expect(fakeApi.lastBannersPlaceholder, isNull);
      });

      test('THEN does not touch the stories placeholder', () async {
        await manager.setBannersPlaceholder();

        expect(fakeApi.storiesPlaceholderCalled, isFalse);
      });
    });
  });
}
