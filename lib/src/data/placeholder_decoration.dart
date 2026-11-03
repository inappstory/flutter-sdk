import 'dart:ui';

import '../generated/appearance_manager.g.dart' show PlaceholderDecorationDto;

/// Loading placeholder decoration: a background [color] and/or a centered
/// asset [image].
///
/// Used by `AppearanceManager.setStoriesPlaceholder` and
/// `AppearanceManager.setBannersPlaceholder`.
class PlaceholderDecoration {
  final Color? color;
  final String? image;

  const PlaceholderDecoration({
    this.color,
    this.image,
  });

  PlaceholderDecorationDto toDto() {
    return PlaceholderDecorationDto(
      color: color?.toARGB32(),
      image: image,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceholderDecoration &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          image == other.image;

  @override
  int get hashCode => color.hashCode ^ image.hashCode;
}
