import 'dart:async';
import 'dart:io';
import 'dart:ui';

import '../generated/pigeon_generated.g.dart'
    show
        InAppStoryAPIListSubscriberFlutterApi,
        StoryAPIDataDto,
        IASStoryListHostApi,
        StoryFavoriteItemAPIDataDto;
import 'observable.dart';
import 'story.dart';

class PigeonStory
    implements Story, InAppStoryAPIListSubscriberFlutterApi {
  PigeonStory(
      this.dto, this.feed, this.iasStoryListHostApi, this.observable);

  StoryAPIDataDto dto;

  final String feed;

  final IASStoryListHostApi iasStoryListHostApi;

  final Observable<InAppStoryAPIListSubscriberFlutterApi> observable;

  late final controller = StreamController.broadcast(
    onListen: onListen,
    onCancel: onCancel,
  );

  void onListen() {
    observable.addObserver(this);
  }

  void onCancel() {
    observable.removeObserver(this);
  }

  @override
  File? get imageFile => nullableFileFromString(dto.imageFilePath);

  @override
  File? get videoFile => nullableFileFromString(dto.videoFilePath);

  @override
  double get aspectRatio => dto.aspectRatio;

  @override
  Color get backgroundColor => colorFromString(dto.backgroundColor);

  @override
  bool get hasAudio => dto.hasAudio;

  @override
  bool get opened => dto.opened;

  @override
  String get title => dto.title;

  @override
  Color get titleColor => colorFromString(dto.titleColor);

  @override
  void showReader() => iasStoryListHostApi.openStoryReader(dto.id, feed);

  void wasViewed() {
    iasStoryListHostApi.updateVisiblePreviews([dto.id], feed);
  }

  @override
  Future<void> updateStoriesData(List<StoryAPIDataDto?> list) async {}

  @override
  Future<void> updateStoryData(StoryAPIDataDto newDto) async {
    if (newDto.id != dto.id || !controller.hasListener) return;
    controller.add(dto = newDto);
  }

  @override
  Future<void> updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto?> list) async {}

  @override
  Stream<void> get updates => controller.stream;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PigeonStory &&
          runtimeType == other.runtimeType &&
          dto.id == other.dto.id;

  @override
  int get hashCode => dto.id;

  @override
  int get id => dto.id;

  @override
  Future<void> storiesLoaded(int size, String feed) async {}

  @override
  Future<void> scrollToStory(int index, String feed, String uniqueId) async {}

  @override
  Future<void> storiesUpdateFailure(String feed, String? reason) async {}
}

typedef StoryFromPigeonDto = PigeonStory;

File? nullableFileFromString(String? filePath) {
  if (filePath == null || filePath.trim().isEmpty) return null;

  return File(filePath);
}

Color colorFromString(String string) {
  if (string.isEmpty) return Color(0x00000000);
  return Color(
    int.parse(
      string.replaceAll(RegExp('^#'), '0xff'),
    ),
  );
}
