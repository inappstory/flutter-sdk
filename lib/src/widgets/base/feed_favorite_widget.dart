import 'package:flutter/material.dart';

import '../../data/feed_favorite.dart';

class FeedFavoriteWidget extends StatelessWidget {
  const FeedFavoriteWidget(this.favorite, {super.key});

  final FeedFavorite favorite;

  Image? get imageNullable {
    final imageFile = favorite.imageFile;

    if (imageFile == null) return null;

    return Image.file(
      imageFile,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: imageNullable ?? ColoredBox(color: favorite.backgroundColor),
    );
  }
}
