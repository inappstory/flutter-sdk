import 'package:flutter/material.dart';

class FeedStoryDecorator {
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry feedPadding;
  final double storyPadding;
  final double loaderAspectRatio;
  final double favouriteAspectRatio;

  final bool showBorder;
  final double borderWidth;
  final double borderPadding;
  final Color borderColor;

  final BoxDecoration foregroundDecoration;

  final ScrollPhysics? scrollPhysics;
  final bool animateScrollToItems;
  final Duration scrollDuration;
  final Curve scrollCurve;

  final EdgeInsetsGeometry textPadding;
  final double textFontSize;
  final TextStyle? textStyle;

  final LoaderDecorator loaderDecorator;

  const FeedStoryDecorator({
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.feedPadding = const EdgeInsets.all(0.0),
    this.textPadding = const EdgeInsets.all(4.0),
    this.storyPadding = 8.0,
    this.textFontSize = 12.0,
    this.loaderAspectRatio = 1 / 1,
    this.favouriteAspectRatio = 1 / 1,
    this.showBorder = true,
    this.borderWidth = 1.0,
    this.borderPadding = 2.0,
    this.borderColor = Colors.black87,
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
    this.scrollPhysics,
    this.animateScrollToItems = false,
    this.scrollCurve = Curves.easeInOut,
    this.scrollDuration = const Duration(milliseconds: 300),
    this.textStyle,
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
