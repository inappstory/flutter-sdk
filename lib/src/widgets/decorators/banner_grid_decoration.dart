/// Appearance of a `BannerGrid`. Values are in logical pixels.
class BannerGridDecoration {
  const BannerGridDecoration({
    this.horizontalGap = 8,
    this.verticalGap = 8,
    this.cornerRadius = 16,
    this.columns = 2,
  });

  /// Distance between grid columns.
  final double horizontalGap;

  /// Distance between grid rows.
  final double verticalGap;

  /// Corner radius of each banner.
  final double cornerRadius;

  /// Number of columns in the grid.
  final int columns;

  /// Alias for [columns].
  int get columnCount => columns;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BannerGridDecoration &&
          horizontalGap == other.horizontalGap &&
          verticalGap == other.verticalGap &&
          cornerRadius == other.cornerRadius &&
          columns == other.columns;

  @override
  int get hashCode =>
      Object.hash(horizontalGap, verticalGap, cornerRadius, columns);
}
