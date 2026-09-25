import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/controllers/feed_stories_controller.dart';
import 'package:inappstory_plugin/src/widgets/grid_view_favourites_widget.dart';

class _TrackingNavigatorObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    popCount++;
  }
}

void main() {
  group('$GridViewFavouritesWidget', () {
    testWidgets(
        'WHEN favorites arrive after an empty update and are removed THEN the route closes',
        (tester) async {
      final stream = StreamController<Iterable<Widget>>.broadcast(sync: true);
      final observer = _TrackingNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    body: GridViewFavouritesWidget(
                      feed: 'feedA',
                      storiesStream: stream.stream,
                    ),
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      stream.add(<Widget>[]);
      await tester.pump();

      stream.add(<Widget>[const SizedBox(key: ValueKey('favorite'))]);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(observer.popCount, 0);
      expect(find.byKey(const ValueKey('favorite')), findsOneWidget);

      stream.add(<Widget>[]);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(observer.popCount, 1);
      expect(find.text('Open'), findsOneWidget);

      await stream.close();
    });

    testWidgets('WHEN favorites fail to load THEN retry reloads the feed',
        (tester) async {
      final stream = StreamController<Iterable<Widget>>.broadcast(sync: true);
      final observer = _TrackingNavigatorObserver();
      var reloadCount = 0;
      final controller = FeedStoriesController()
        ..attach(() async => reloadCount++);

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    body: GridViewFavouritesWidget(
                      feed: 'feedA',
                      controller: controller,
                      storiesStream: stream.stream,
                    ),
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      stream.addError(Exception('load failed'));
      await tester.pump();
      expect(find.text('Не удалось загрузить избранное'), findsOneWidget);
      expect(observer.popCount, 0);

      await tester.tap(find.text('Повторить'));
      await tester.pump();

      expect(reloadCount, 1);
      expect(observer.popCount, 0);

      await stream.close();
    });
  });
}
