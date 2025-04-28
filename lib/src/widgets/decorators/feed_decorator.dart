import 'package:flutter/material.dart';

class FeedStoryDecorator {
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry feedPadding;
  final double storyPadding;

  final BoxDecoration foregroundDecoration;

  final EdgeInsetsGeometry textPadding;
  final double textFontSize;

  final LoaderDecorator loaderDecorator;

  const FeedStoryDecorator({
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.feedPadding = const EdgeInsets.all(10.0),
    this.textPadding = const EdgeInsets.all(4.0),
    this.storyPadding = 8.0,
    this.textFontSize = 14.0,
    this.loaderDecorator = const LoaderDecorator(),
    this.foregroundDecoration = const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black87,
        ],
      ),
    ),
  });
}

class LoaderDecorator {
  final Color baseColor;
  final Color highlightColor;

  const LoaderDecorator({
    this.baseColor = const Color.fromARGB(255, 224, 224, 224),
    this.highlightColor = const Color.fromARGB(255, 158, 158, 158),
  });
}
