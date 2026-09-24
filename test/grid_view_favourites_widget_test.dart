import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/widgets/grid_view_favourites_widget.dart';

class _TrackingNavigatorObserver extends NavigatorObserver {
  final poppedRoutes = <Route<dynamic>>[];
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    popCount++;
    poppedRoutes.add(route);
  }
}

void main() {
  group('$GridViewFavouritesWidget', () {
    group('GIVEN widget mounted in a pushed route', () {
      late StreamController<Iterable<Widget>> controller;
      late _TrackingNavigatorObserver navObserver;

      setUp(() {
        controller = StreamController<Iterable<Widget>>.broadcast(sync: true);
        navObserver = _TrackingNavigatorObserver();
      });

      tearDown(() async {
        await controller.close();
      });

      Future<void> pumpHarness(
        WidgetTester tester, {
        Widget Function(BuildContext)? loaderBuilder,
        Widget Function(BuildContext, Object?)? errorBuilder,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [navObserver],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          body: GridViewFavouritesWidget(
                            feed: 'feedA',
                            storiesStream: controller.stream,
                            loaderBuilder: loaderBuilder,
                            errorBuilder: errorBuilder,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
      }

      testWidgets(
          'WHEN waiting for data '
          'THEN loaderBuilder is shown and route remains open', (tester) async {
        await pumpHarness(
          tester,
          loaderBuilder: (_) => const Text('Loading...'),
        );

        expect(find.text('Loading...'), findsOneWidget);
        expect(find.byType(GridViewFavouritesWidget), findsOneWidget);
        expect(navObserver.popCount, 0);
      });

      testWidgets(
          'WHEN stream emits error '
          'THEN errorBuilder is shown and route remains open', (tester) async {
        await pumpHarness(
          tester,
          errorBuilder: (_, error) => Text('Error: $error'),
        );

        controller.addError(Exception('network error'));
        await tester.pump();

        expect(find.text('Error: Exception: network error'), findsOneWidget);
        expect(find.byType(GridViewFavouritesWidget), findsOneWidget);
        expect(navObserver.popCount, 0);
      });

      testWidgets(
          'WHEN stream emits non-empty list '
          'THEN items are displayed and route remains open', (tester) async {
        await pumpHarness(tester);

        controller.add([
          const Text('Story 1'),
          const Text('Story 2'),
        ]);
        await tester.pump();

        expect(find.text('Story 1'), findsOneWidget);
        expect(find.text('Story 2'), findsOneWidget);
        expect(find.byType(GridViewFavouritesWidget), findsOneWidget);
        expect(navObserver.popCount, 0);
      });

      testWidgets(
          'WHEN empty favorites list is emitted '
          'THEN the route closes without throwing setState during build',
          (tester) async {
        await pumpHarness(tester);

        expect(find.byType(GridViewFavouritesWidget), findsOneWidget);

        controller.add(<Widget>[]);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(GridViewFavouritesWidget), findsNothing);
        expect(navObserver.popCount, 1);
        expect(navObserver.poppedRoutes.single, isA<MaterialPageRoute>());
      });

      testWidgets(
          'WHEN non-empty list is followed by empty list '
          'THEN items are displayed first and then route closes',
          (tester) async {
        await pumpHarness(tester);

        controller.add([const Text('Story 1')]);
        await tester.pump();

        expect(find.text('Story 1'), findsOneWidget);
        expect(navObserver.popCount, 0);

        controller.add(<Widget>[]);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(GridViewFavouritesWidget), findsNothing);
        expect(navObserver.popCount, 1);
      });

      testWidgets(
          'WHEN stream emits multiple empty events '
          'THEN only one pop occurs and root route remains intact',
          (tester) async {
        await pumpHarness(tester);

        // Multiple empty events in quick succession.
        controller.add(<Widget>[]);
        controller.add(<Widget>[]);
        await tester.pump();

        // Trigger additional rebuilds.
        controller.add(<Widget>[]);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(GridViewFavouritesWidget), findsNothing);
        expect(navObserver.popCount, 1);
        expect(find.text('Open'), findsOneWidget);
      });

      testWidgets(
          'WHEN another route is pushed on top '
          'THEN emitting empty does not pop the foreign route', (tester) async {
        await pumpHarness(tester);

        // Push another dialog/route on top of the favorites widget.
        final context = tester.element(find.byType(GridViewFavouritesWidget));
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(title: Text('Top Dialog')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Top Dialog'), findsOneWidget);

        // Emit empty favorites while the dialog is on top.
        controller.add(<Widget>[]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // The top dialog must NOT be popped by GridViewFavouritesWidget.
        expect(find.text('Top Dialog'), findsOneWidget);
        expect(navObserver.popCount, 0);
      });

      testWidgets(
          'WHEN the route is already popped '
          'THEN emitting empty does not pop again', (tester) async {
        await pumpHarness(tester);

        // User pops the route.
        Navigator.of(tester.element(find.byType(GridViewFavouritesWidget)))
            .pop();
        await tester.pumpAndSettle();

        expect(navObserver.popCount, 1);
        expect(find.byType(GridViewFavouritesWidget), findsNothing);

        // Controller emits empty afterwards.
        controller.add(<Widget>[]);
        await tester.pump();
        await tester.pumpAndSettle();

        // Pop count should still be 1 (root route wasn't popped).
        expect(navObserver.popCount, 1);
        expect(find.text('Open'), findsOneWidget);
      });
    });

    group('GIVEN widget mounted without a ModalRoute', () {
      testWidgets('WHEN empty list is emitted THEN it does not throw',
          (tester) async {
        final controller =
            StreamController<Iterable<Widget>>.broadcast(sync: true);

        await tester.pumpWidget(
          GridViewFavouritesWidget(
            feed: 'feedA',
            storiesStream: controller.stream,
          ),
        );

        controller.add(<Widget>[]);
        await tester.pump();

        expect(tester.takeException(), isNull);
        await controller.close();
      });
    });
  });
}
