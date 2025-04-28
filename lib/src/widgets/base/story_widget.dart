import 'package:flutter/widgets.dart';

import '../../data/story.dart';

abstract class StoryWidget implements Widget {
  abstract final Story story;
}
