import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart'
    show FeedReloadCallback, FeedStoriesController, FeedStoriesWidget;

/// Records the binding calls the widget makes on its controller.
class RecordingController extends FeedStoriesController {
  final binds = <String>[];

  @override
  void attach(FeedReloadCallback reload) {
    binds.add('attach');
    super.attach(reload);
  }

  @override
  void detach(FeedReloadCallback reload) {
    binds.add('detach');
    super.detach(reload);
  }
}

void main() {
  testWidgets('GIVEN a mounted widget WHEN its controller is swapped '
      'THEN the new controller takes over the binding', (tester) async {
    final first = RecordingController();
    final second = RecordingController();

    await tester.pumpWidget(MaterialApp(
      home: FeedStoriesWidget(feed: 'feedA', controller: first),
    ));

    expect(first.binds, ['attach']);

    // Same type and position, so the State is reused: didUpdateWidget runs.
    await tester.pumpWidget(MaterialApp(
      home: FeedStoriesWidget(feed: 'feedA', controller: second),
    ));

    expect(second.binds, ['attach'], reason: 'new controller must be bound');
    expect(first.binds, ['attach', 'detach'], reason: 'old one must be freed');
  });

  testWidgets('GIVEN a disposed widget WHEN a new one mounts with the same '
      'controller THEN the controller is bound again', (tester) async {
    final controller = RecordingController();

    await tester.pumpWidget(MaterialApp(
      home: FeedStoriesWidget(feed: 'feedA', controller: controller),
    ));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    expect(controller.binds, ['attach', 'detach']);

    await tester.pumpWidget(MaterialApp(
      home: FeedStoriesWidget(feed: 'feedA', controller: controller),
    ));

    expect(controller.binds, ['attach', 'detach', 'attach']);
  });

  // The feed stream starts in ConnectionState.waiting on the first frame
  // (no native emission), so the loading branch is what these exercise.
  const loaderKey = Key('loader');

  testWidgets('GIVEN a loaderBuilder WHEN the feed is loading '
      'THEN the loader is shown at the widget height', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FeedStoriesWidget(
        feed: 'feedA',
        height: 200,
        loaderBuilder: (context) => const SizedBox(key: loaderKey),
      ),
    ));

    expect(find.byKey(loaderKey), findsOneWidget);
    final box = tester.widget<SizedBox>(
      find
          .ancestor(of: find.byKey(loaderKey), matching: find.byType(SizedBox))
          .first,
    );
    expect(box.height, 200);
  });

  testWidgets('GIVEN no loaderBuilder WHEN the feed is loading '
      'THEN nothing is rendered', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: FeedStoriesWidget(feed: 'feedA'),
    ));

    // The loading branch collapses to SizedBox.shrink() — no sized content.
    final shrink = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(FeedStoriesWidget),
        matching: find.byType(SizedBox),
      ),
    );
    expect(shrink.height, 0);
    expect(shrink.width, 0);
  });
}
