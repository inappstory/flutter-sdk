import 'package:flutter/widgets.dart';

class StoryPlaceholder extends StatelessWidget {
  const StoryPlaceholder({super.key, required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: backgroundColor);
  }
}
