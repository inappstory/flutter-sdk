import 'package:flutter/widgets.dart';

import '../generated/pigeon_generated.g.dart'
    show OnboardingLoadCallbackFlutterApi;

mixin IASOnboardingLoadCallback<T extends StatefulWidget> on State<T>
    implements OnboardingLoadCallbackFlutterApi {
  @override
  void initState() {
    super.initState();
    OnboardingLoadCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    OnboardingLoadCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  Future<void> onboardingLoadSuccess(int count, String feed) async {}

  @override
  Future<void> onboardingLoadError(String feed, String? reason) async {}
}
