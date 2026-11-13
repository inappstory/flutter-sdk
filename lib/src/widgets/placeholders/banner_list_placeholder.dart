import 'package:flutter/material.dart';

import '../../helpers/shimmer.dart';

/// A vertical shimmer placeholder for banner lists.
///
/// Use this widget as the `bannerPlaceLoaderBuilder` value to show a placeholder
/// while banners are loading.
class BannerListPlaceholder extends StatelessWidget {
  /// Creates a [BannerListPlaceholder].
  const BannerListPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 224, 224, 224),
      highlightColor: const Color.fromARGB(255, 158, 158, 158),
      child: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      ),
    );
  }
}
