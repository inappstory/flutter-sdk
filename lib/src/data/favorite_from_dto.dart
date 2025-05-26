import 'dart:io';
import 'dart:ui';

import '../pigeon_generated.g.dart';
import 'feed_favorite.dart';
import 'story_from_pigeon_dto.dart';

class FavoriteFromDto implements FeedFavorite {
  FavoriteFromDto(this.dto);

  final StoryFavoriteItemAPIDataDto dto;

  @override
  File? get imageFile => nullableFileFromString(dto.imageFilePath);

  @override
  Color get backgroundColor => colorFromString(dto.backgroundColor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FavoriteFromDto && runtimeType == other.runtimeType && dto.id == other.dto.id;

  @override
  int get hashCode => dto.id;

  @override
  int get id => dto.id;
}
