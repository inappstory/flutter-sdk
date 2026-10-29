import 'package:flutter/foundation.dart';

import '../generated/pigeon_generated.g.dart'
    show InAppMessageTypeDto, InAppMessageDataDto;

/// Type of in-app message display presentation.
enum InAppMessageType {
  fullScreen,
  bottomSheet,
  popUp,
  toast,
  undefined;

  @internal
  static InAppMessageType fromDto(InAppMessageTypeDto dto) {
    return switch (dto) {
      InAppMessageTypeDto.fullScreen => InAppMessageType.fullScreen,
      InAppMessageTypeDto.bottomSheet => InAppMessageType.bottomSheet,
      InAppMessageTypeDto.popUp => InAppMessageType.popUp,
      InAppMessageTypeDto.toast => InAppMessageType.toast,
      InAppMessageTypeDto.undefined => InAppMessageType.undefined,
    };
  }

  @internal
  InAppMessageTypeDto toDto() {
    return switch (this) {
      InAppMessageType.fullScreen => InAppMessageTypeDto.fullScreen,
      InAppMessageType.bottomSheet => InAppMessageTypeDto.bottomSheet,
      InAppMessageType.popUp => InAppMessageTypeDto.popUp,
      InAppMessageType.toast => InAppMessageTypeDto.toast,
      InAppMessageType.undefined => InAppMessageTypeDto.undefined,
    };
  }
}

/// Represents data for an in-app message.
@immutable
class InAppMessageData {
  const InAppMessageData({
    required this.id,
    this.title,
    this.event,
    this.messageType,
    this.extraFields,
  });

  final int id;
  final String? title;
  final String? event;
  final InAppMessageType? messageType;
  final Map<String, String>? extraFields;

  @internal
  factory InAppMessageData.fromDto(InAppMessageDataDto dto) {
    return InAppMessageData(
      id: dto.id,
      title: dto.title,
      event: dto.event,
      messageType: dto.messageType == null
          ? null
          : InAppMessageType.fromDto(dto.messageType!),
      extraFields: dto.extraFields == null
          ? null
          : Map<String, String>.unmodifiable(dto.extraFields!),
    );
  }

  @internal
  InAppMessageDataDto toDto() {
    return InAppMessageDataDto(
      id: id,
      title: title,
      event: event,
      messageType: messageType?.toDto(),
      extraFields: extraFields,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppMessageData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          event == other.event &&
          messageType == other.messageType &&
          mapEquals(extraFields, other.extraFields);

  @override
  int get hashCode => Object.hash(
        id,
        title,
        event,
        messageType,
        extraFields == null ? 0 : Object.hashAll(extraFields!.entries),
      );

  @override
  String toString() {
    return 'InAppMessageData(id: $id, title: $title, event: $event, messageType: $messageType)';
  }
}
