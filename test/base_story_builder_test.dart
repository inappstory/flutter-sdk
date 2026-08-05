import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/data/story.dart';
import 'package:inappstory_plugin/src/widgets/builders/base_story_builder.dart';
import 'package:inappstory_plugin/src/widgets/decorators/feed_decorator.dart';
import 'package:inappstory_plugin/src/widgets/placeholders/story_placeholder.dart';

/// No image/video files, so the content collapses to a [StoryPlaceholder] —
/// keeps the widget test free of file/native dependencies.
class FakeStory implements Story {
  FakeStory({this.isOpened = false, this.titleValue = 'My Story'});

  final bool isOpened;
  final String titleValue;
  bool showReaderCalled = false;

  @override
  int get id => 1;
  @override
  Stream<void> get updates => const Stream.empty();
  @override
  String get title => titleValue;
  @override
  double get aspectRatio => 1.0;
  @override
  File? get imageFile => null;
  @override
  File? get videoFile => null;
  @override
  bool get hasAudio => false;
  @override
  bool get opened => isOpened;
  @override
  Color get backgroundColor => const Color(0xFF112233);
  @override
  Color get titleColor => const Color(0xFFFFFFFF);
  @override
  void showReader() => showReaderCalled = true;
}

void main() {
  Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

  Border borderOf(WidgetTester tester) {
    final container = tester.widget<Container>(find.byType(Container));
    return (container.decoration as BoxDecoration).border as Border;
  }

  group('$BaseStoryBuilder', () {
    testWidgets('WHEN built THEN it shows the title over a placeholder',
        (tester) async {
      await pump(
        tester,
        BaseStoryBuilder(
          FakeStory(titleValue: 'Hello'),
          decorator: const FeedStoryDecorator(),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(StoryPlaceholder), findsOneWidget);
    });

    testWidgets('WHEN tapped with no onStoryTap THEN the reader is opened',
        (tester) async {
      final story = FakeStory();
      await pump(
        tester,
        BaseStoryBuilder(story, decorator: const FeedStoryDecorator()),
      );

      await tester.tap(find.byType(BaseStoryBuilder));

      expect(story.showReaderCalled, isTrue);
    });

    // Regression: Container had a hardcoded Clip.antiAlias, which asserts when
    // the decoration is null (no border) — crashing the widget.
    testWidgets('WHEN there is no border THEN it builds without crashing',
        (tester) async {
      await pump(
        tester,
        BaseStoryBuilder(
          FakeStory(titleValue: 'Hi'),
          decorator: const FeedStoryDecorator(showBorder: false),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Hi'), findsOneWidget);
    });

    testWidgets('WHEN there is no decorator THEN it builds without crashing',
        (tester) async {
      await pump(tester, BaseStoryBuilder(FakeStory(titleValue: 'Hi')));

      expect(tester.takeException(), isNull);
      expect(find.text('Hi'), findsOneWidget);
    });

    group('WHEN the decorator shows a border', () {
      testWidgets('AND the story is closed THEN the border uses borderColor',
          (tester) async {
        await pump(
          tester,
          BaseStoryBuilder(
            FakeStory(isOpened: false),
            decorator: const FeedStoryDecorator(borderColor: Color(0xFFAA0000)),
          ),
        );

        expect(borderOf(tester).top.color, const Color(0xFFAA0000));
      });

      testWidgets('AND the story is opened THEN the border is transparent',
          (tester) async {
        await pump(
          tester,
          BaseStoryBuilder(
            FakeStory(isOpened: true),
            decorator: const FeedStoryDecorator(borderColor: Color(0xFFAA0000)),
          ),
        );

        expect(borderOf(tester).top.color, Colors.transparent);
      });
    });
  });
}
