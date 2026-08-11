import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/data/feed_favorite.dart';
import 'package:inappstory_plugin/src/widgets/feed_list_favorites_item_widget.dart';

class FakeFavorite implements FeedFavorite {
  FakeFavorite(this.id);

  @override
  final int id;

  @override
  File? get imageFile => null;

  @override
  Color get backgroundColor => const Color(0xFF000000);
}

void main() {
  Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

  group('$FeedFavoritesItemWidget', () {
    group('WHEN built with favorites', () {
      testWidgets('THEN the grid has one item per favorite', (tester) async {
        await pump(
          tester,
          FeedFavoritesItemWidget(
            [FakeFavorite(1), FakeFavorite(2), FakeFavorite(3)],
            feedFavoriteWidgetBuilder: (_) => const SizedBox(),
          ),
        );

        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate = grid.childrenDelegate as SliverChildBuilderDelegate;
        expect(delegate.childCount, 3);
      });

      testWidgets('THEN the builder receives each favorite', (tester) async {
        final received = <int>[];
        await pump(
          tester,
          FeedFavoritesItemWidget(
            [FakeFavorite(7)],
            feedFavoriteWidgetBuilder: (favorite) {
              received.add(favorite.id);
              return const SizedBox();
            },
          ),
        );

        expect(received, [7]);
      });
    });

    group('WHEN built with no favorites', () {
      testWidgets('THEN the grid is empty', (tester) async {
        await pump(
          tester,
          FeedFavoritesItemWidget(
            const [],
            feedFavoriteWidgetBuilder: (_) => const SizedBox(),
          ),
        );

        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate = grid.childrenDelegate as SliverChildBuilderDelegate;
        expect(delegate.childCount, 0);
      });
    });

    group('WHEN built without a decorator', () {
      testWidgets('THEN the grid uses 2 columns and aspect ratio 1.0',
          (tester) async {
        await pump(
          tester,
          FeedFavoritesItemWidget(
            [FakeFavorite(1)],
            feedFavoriteWidgetBuilder: (_) => const SizedBox(),
          ),
        );

        final grid = tester.widget<GridView>(find.byType(GridView));
        final gridDelegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(gridDelegate.crossAxisCount, 2);
        expect(gridDelegate.childAspectRatio, 1.0);
      });
    });
  });
}
