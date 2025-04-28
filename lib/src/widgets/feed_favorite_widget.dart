import 'package:flutter/widgets.dart';

import '../data/feed_favorite.dart';

class FeedFavoriteWidget extends StatelessWidget {
  const FeedFavoriteWidget(this.favorite, {super.key});

  final FeedFavorite favorite;

  Image? get imageNullable {
    final imageFile = favorite.imageFile;

    if (imageFile == null) return null;

    return Image.file(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1,
              child: imageNullable ?? ColoredBox(color: favorite.backgroundColor),
            ),
          ],
        ),
      ),
    );
  }
}
