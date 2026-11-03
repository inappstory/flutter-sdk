import 'package:flutter/foundation.dart';

import '../generated/pigeon_generated.g.dart'
    show StoryTypeDto, SourceTypeDto, ClickActionDto, StoryDataDto, SlideDataDto;

/// Type of story.
enum StoryType {
  common,
  ugc,
  iam,
  banner;

  @internal
  static StoryType fromDto(StoryTypeDto dto) {
    return switch (dto) {
      StoryTypeDto.common => StoryType.common,
      StoryTypeDto.ugc => StoryType.ugc,
      StoryTypeDto.iam => StoryType.iam,
      StoryTypeDto.banner => StoryType.banner,
    };
  }

  @internal
  StoryTypeDto toDto() {
    return switch (this) {
      StoryType.common => StoryTypeDto.common,
      StoryType.ugc => StoryTypeDto.ugc,
      StoryType.iam => StoryTypeDto.iam,
      StoryType.banner => StoryTypeDto.banner,
    };
  }
}

/// Source type of stories or slides.
enum SourceType {
  single,
  onboarding,
  list,
  favorite,
  stack,
  inAppMessage,
  banners;

  @internal
  static SourceType fromDto(SourceTypeDto dto) {
    return switch (dto) {
      SourceTypeDto.single => SourceType.single,
      SourceTypeDto.onboarding => SourceType.onboarding,
      SourceTypeDto.list => SourceType.list,
      SourceTypeDto.favorite => SourceType.favorite,
      SourceTypeDto.stack => SourceType.stack,
      SourceTypeDto.inAppMessage => SourceType.inAppMessage,
      SourceTypeDto.banners => SourceType.banners,
    };
  }

  @internal
  SourceTypeDto toDto() {
    return switch (this) {
      SourceType.single => SourceTypeDto.single,
      SourceType.onboarding => SourceTypeDto.onboarding,
      SourceType.list => SourceTypeDto.list,
      SourceType.favorite => SourceTypeDto.favorite,
      SourceType.stack => SourceTypeDto.stack,
      SourceType.inAppMessage => SourceTypeDto.inAppMessage,
      SourceType.banners => SourceTypeDto.banners,
    };
  }
}

/// Action performed on a slide CTA.
enum ClickAction {
  button,
  swipe,
  game,
  deeplink;

  @internal
  static ClickAction fromDto(ClickActionDto dto) {
    return switch (dto) {
      ClickActionDto.button => ClickAction.button,
      ClickActionDto.swipe => ClickAction.swipe,
      ClickActionDto.game => ClickAction.game,
      ClickActionDto.deeplink => ClickAction.deeplink,
    };
  }

  @internal
  ClickActionDto toDto() {
    return switch (this) {
      ClickAction.button => ClickActionDto.button,
      ClickAction.swipe => ClickActionDto.swipe,
      ClickAction.game => ClickActionDto.game,
      ClickAction.deeplink => ClickActionDto.deeplink,
    };
  }
}

/// Represents information about a story.
@immutable
class StoryData {
  const StoryData({
    required this.id,
    this.title,
    this.tags,
    this.feed,
    this.sourceType,
    this.slidesCount = 0,
    this.storyType,
    this.extraFields,
  });

  final int id;
  final String? title;
  final String? tags;
  final String? feed;
  final SourceType? sourceType;
  final int slidesCount;
  final StoryType? storyType;
  final Map<String, String>? extraFields;

  @internal
  factory StoryData.fromDto(StoryDataDto dto) {
    return StoryData(
      id: dto.id,
      title: dto.title,
      tags: dto.tags,
      feed: dto.feed,
      sourceType:
          dto.sourceType == null ? null : SourceType.fromDto(dto.sourceType!),
      slidesCount: dto.slidesCount,
      storyType:
          dto.storyType == null ? null : StoryType.fromDto(dto.storyType!),
      extraFields: dto.extraFields == null
          ? null
          : Map<String, String>.unmodifiable(dto.extraFields!),
    );
  }

  @internal
  StoryDataDto toDto() {
    return StoryDataDto(
      id: id,
      title: title,
      tags: tags,
      feed: feed,
      sourceType: sourceType?.toDto(),
      slidesCount: slidesCount,
      storyType: storyType?.toDto(),
      extraFields: extraFields,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          tags == other.tags &&
          feed == other.feed &&
          sourceType == other.sourceType &&
          slidesCount == other.slidesCount &&
          storyType == other.storyType &&
          mapEquals(extraFields, other.extraFields);

  @override
  int get hashCode => Object.hash(
        id,
        title,
        tags,
        feed,
        sourceType,
        slidesCount,
        storyType,
        extraFields == null ? 0 : Object.hashAll(extraFields!.entries),
      );

  @override
  String toString() {
    return 'StoryData(id: $id, title: $title, feed: $feed, slidesCount: $slidesCount)';
  }
}

/// Represents slide data in a story callback.
@immutable
class SlideData {
  const SlideData({
    this.story,
    required this.index,
    this.payload,
  });

  final StoryData? story;
  final int index;
  final String? payload;

  @internal
  factory SlideData.fromDto(SlideDataDto dto) {
    return SlideData(
      story: dto.story == null ? null : StoryData.fromDto(dto.story!),
      index: dto.index,
      payload: dto.payload,
    );
  }

  @internal
  SlideDataDto toDto() {
    return SlideDataDto(
      story: story?.toDto(),
      index: index,
      payload: payload,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlideData &&
          runtimeType == other.runtimeType &&
          story == other.story &&
          index == other.index &&
          payload == other.payload;

  @override
  int get hashCode => Object.hash(story, index, payload);

  @override
  String toString() {
    return 'SlideData(story: ${story?.id}, index: $index, payload: $payload)';
  }
}
