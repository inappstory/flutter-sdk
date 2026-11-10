/// Appearance of a `BannerList`. Values are in logical pixels.
class BannerListDecoration {
  const BannerListDecoration({
    this.edgePadding,
    this.verticalGap,
    this.cornerRadius,
  });

  /// Padding between the list items and the horizontal edges.
  final double? edgePadding;

  /// Distance between list items.
  final double? verticalGap;

  /// Corner radius of each banner.
  final double? cornerRadius;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BannerListDecoration &&
          edgePadding == other.edgePadding &&
          verticalGap == other.verticalGap &&
          cornerRadius == other.cornerRadius;

  @override
  int get hashCode => Object.hash(edgePadding, verticalGap, cornerRadius);
}
