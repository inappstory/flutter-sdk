import 'package:meta/meta.dart';

import '../generated/pigeon_generated_private.g.dart';

@protected
class IASStatisticsManager {
  @protected
  static Future<void> sendStatistics(bool value) async {
    await InAppStoryStatManagerHostApi().sendStatistics(value);
  }
}
