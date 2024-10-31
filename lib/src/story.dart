import 'dart:io';
import 'dart:ui';

abstract class Story {
  Stream<void> get updates;

  String get title;

  double get aspectRatio;

  File? get imageFile;

  File? get videoFile;

  bool get hasAudio;

  bool get opened;

  Color get backgroundColor;

  Color get titleColor;

  void tap();
}
