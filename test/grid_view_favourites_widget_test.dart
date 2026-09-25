import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    testWidgets('WHEN favorites become empty THEN only its route is popped',
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
      stream.add(<Widget>[]);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(observer.popCount, 1);
      expect(find.text('Open'), findsOneWidget);

      await stream.close();
    });
  });
}
