import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:inappstory_plugin/inappstory_plugin.dart';

class StoryFromPigeonDto implements Story, InAppStoryAPIListSubscriberFlutterApi {
  StoryFromPigeonDto(this.dto);

  StoryAPIDataDto dto;

  final iasStoryListHostApi = IASStoryListHostApi();

  late final controller = StreamController.broadcast(
    onListen: onListen,
    onCancel: onCancel,
  );

  void onListen() {
    InAppStoryAPIListSubscriberFlutterApi.setUp(this);
  }

  void onCancel() {
    InAppStoryAPIListSubscriberFlutterApi.setUp(null);
  }

  File? nullableFileFromString(String? filePath) {
    if (filePath == null || filePath.trim().isEmpty) return null;

    return File(filePath);
  }

  Color colorFromString(String string) {
    return Color(
      int.parse(
        string.replaceAll(RegExp('^#'), '0xff'),
      ),
    );
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
  void tap() => iasStoryListHostApi.openStoryReader(dto.id);

  @override
  void readerIsClosed() {}

  @override
  void readerIsOpened() {}

  @override
  void storyIsOpened(int var1) {}

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {}

  @override
  void updateStoryData(StoryAPIDataDto newDto) => controller.add(dto = newDto);

  @override
  Stream<void> get updates => controller.stream;
}
