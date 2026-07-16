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
}
