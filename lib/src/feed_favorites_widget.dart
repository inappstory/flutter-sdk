import 'package:flutter/widgets.dart';
import 'package:inappstory_plugin/src/favorite_from_dto.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'pigeon_generated.g.dart';

class FeedFavoritesWidget extends StatelessWidget {
  const FeedFavoritesWidget(this.favorites, this.iasStoryListHostApi, {super.key});

  final Iterable<FavoriteFromDto> favorites;
  final IASStoryListHostApi iasStoryListHostApi;

  void onVisibilityChanged(VisibilityInfo info) => iasStoryListHostApi.showFavoriteItem();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey('favorites'),
      onVisibilityChanged: onVisibilityChanged,
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (_, index) => FavoriteWidget(favorites.elementAt(index)),
          itemCount: favorites.length,
        ),
      ),
    );
  }
}

class FavoriteWidget extends StatelessWidget {
  const FavoriteWidget(this.favorite, {super.key});

  final FavoriteFromDto favorite;

  Image? get imageNullable {
    final imageFile = favorite.imageFile;

    if (imageFile == null) return null;

    return Image.file(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 1,
            child: imageNullable ?? ColoredBox(color: favorite.backgroundColor),
          ),
        ],
      ),
    );
  }
}
