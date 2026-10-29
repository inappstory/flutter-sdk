import 'package:flutter/foundation.dart';

import '../generated/pigeon_generated.g.dart'
    show ContentTypeDto, ContentDataDto;
import 'story_data.dart' show SourceType;

/// Type of game content.
enum ContentType {
  story,
  ugc,
  inAppMessage;

  @internal
  static ContentType fromDto(ContentTypeDto dto) {
    return switch (dto) {
      ContentTypeDto.story => ContentType.story,
      ContentTypeDto.ugc => ContentType.ugc,
      ContentTypeDto.inAppMessage => ContentType.inAppMessage,
    };
  }

  @internal
  ContentTypeDto toDto() {
    return switch (this) {
      ContentType.story => ContentTypeDto.story,
      ContentType.ugc => ContentTypeDto.ugc,
      ContentType.inAppMessage => ContentTypeDto.inAppMessage,
    };
  }
}

/// Represents content data for games.
@immutable
class ContentData {
  const ContentData({
    this.contentType,
    this.sourceType,
  });

  final ContentType? contentType;
  final SourceType? sourceType;

  @internal
  factory ContentData.fromDto(ContentDataDto dto) {
    return ContentData(
      contentType: dto.contentType == null
          ? null
          : ContentType.fromDto(dto.contentType!),
      sourceType:
          dto.sourceType == null ? null : SourceType.fromDto(dto.sourceType!),
    );
  }

  @internal
  ContentDataDto toDto() {
    return ContentDataDto(
      contentType: contentType?.toDto(),
      sourceType: sourceType?.toDto(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentData &&
          runtimeType == other.runtimeType &&
          contentType == other.contentType &&
          sourceType == other.sourceType;

  @override
  int get hashCode => Object.hash(contentType, sourceType);

  @override
  String toString() {
    return 'ContentData(contentType: $contentType, sourceType: $sourceType)';
  }
}
