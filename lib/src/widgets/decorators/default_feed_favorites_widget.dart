import 'package:flutter/material.dart';

import '../feed_list_favorites_item_widget.dart';
import '../grid_view_favourites_widget.dart';

class DefaultGridFeedFavoritesWidget extends FeedFavoritesItemWidget {
  const DefaultGridFeedFavoritesWidget(
    super.favorites,
    this.feed, {
    super.key,
    super.decorator,
  });

  final String feed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showFavoritesBottomSheet(context),
      child: super.build(context),
    );
  }

  void showFavoritesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(top: 16),
        height: MediaQuery.of(context).size.height * 0.75,
        child: GridViewFavouritesWidget(
          feed: feed,
          decorator: decorator,
          loaderBuilder: (context) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}
