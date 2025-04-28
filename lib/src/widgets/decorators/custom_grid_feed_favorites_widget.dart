import 'package:flutter/widgets.dart';

import '../grid_feed_favorites_widget.dart';

class CustomGridFeedFavoritesWidget extends GridFeedFavoritesWidget {
  CustomGridFeedFavoritesWidget(super.favorites, {required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: super.build(context),
    );
  }
}
