import 'dart:io';
import 'dart:ui';

import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/story_from_pigeon_dto.dart';

class FavoriteFromDto {
  FavoriteFromDto(this.dto);

  final StoryFavoriteItemAPIDataDto dto;

  File? get imageFile => nullableFileFromString(dto.imageFilePath);

  Color get backgroundColor => colorFromString(dto.backgroundColor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FavoriteFromDto && runtimeType == other.runtimeType && dto.id == other.dto.id;

  @override
  int get hashCode => dto.id;
}
