import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BannerPlacePlaceholder extends StatelessWidget {
  /// Creates a [BannerPlacePlaceholder].
  ///
  /// [decorator] is used to customize the appearance of the loader.
  const BannerPlacePlaceholder({
    super.key,
    this.baseColor,
    this.highlightColor,
    this.borderRadius,
    this.margin,
  });

  /// The decorator for customizing the appearance of the loader.
  final Color? baseColor;
  final Color? highlightColor;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: 3,
      controller: PageController(
        initialPage: 1,
        viewportFraction: 0.85,
      ),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Padding(
          padding: margin ?? const EdgeInsets.all(10.0),
          child: Shimmer.fromColors(
            baseColor: baseColor ?? const Color.fromARGB(255, 224, 224, 224),
            highlightColor:
                highlightColor ?? const Color.fromARGB(255, 158, 158, 158),
            child: ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.circular(16.0),
              child: Container(
                width: 100,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: borderRadius ?? BorderRadius.circular(16.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
