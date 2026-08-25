import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart'
    show InAppStoryPlugin;
import 'package:inappstory_plugin/inappstory_plugin_method_channel.dart';
import 'package:inappstory_plugin/inappstory_plugin_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInappstoryPluginPlatform
    with MockPlatformInterfaceMixin
    implements InappstoryPluginPlatform {
  int initWithCalls = 0;
  List<String>? lastTags;

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> initWith(String apiKey, String userId,
      {bool anonymous = false,
      String? userSign,
      String? languageCode,
      String? languageRegion,
      String? cacheSize,
      List<String>? tags}) async {
    initWithCalls++;
    lastTags = tags;
  }

  @override
  FutureOr<bool> isInitialized() {
    throw UnimplementedError();
  }
}

void main() {
  final InappstoryPluginPlatform initialPlatform =
      InappstoryPluginPlatform.instance;

  test('$MethodChannelInappstoryPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInappstoryPlugin>());
  });

  group('GIVEN InAppStoryPlugin.initWith', () {
    late MockInappstoryPluginPlatform mock;

    setUp(() {
      mock = MockInappstoryPluginPlatform();
      InappstoryPluginPlatform.instance = mock;
    });

    tearDown(() {
      InappstoryPluginPlatform.instance = initialPlatform;
    });

    group('WHEN tags are invalid', () {
      test('THEN the native init runs with empty tags instead of throwing',
          () async {
        await InAppStoryPlugin().initWith('key', 'user', tags: ['bad tag']);

        expect(mock.initWithCalls, 1);
        expect(mock.lastTags, isEmpty);
      });
    });

    group('WHEN tags are valid', () {
      test('THEN they are passed through to the native init', () async {
        await InAppStoryPlugin().initWith('key', 'user', tags: ['sport']);

        expect(mock.initWithCalls, 1);
        expect(mock.lastTags, ['sport']);
      });
    });

    group('WHEN tags are omitted', () {
      test('THEN the native init is called with null tags', () async {
        await InAppStoryPlugin().initWith('key', 'user');

        expect(mock.initWithCalls, 1);
        expect(mock.lastTags, isNull);
      });
    });
  });
}
