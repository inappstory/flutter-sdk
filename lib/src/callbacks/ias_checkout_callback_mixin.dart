import 'package:flutter/widgets.dart';

import '../controllers/ias_manager.dart';
import '../generated/checkout_generated.g.dart';

mixin IASCheckoutCallback<T extends StatefulWidget> on State<T>
    implements CheckoutCallbackFlutterApi {
  /// Sets up the callbacks by registering this mixin instance
  @override
  void initState() {
    super.initState();
    CheckoutCallbackFlutterApi.setUp(this);
  }

  /// Removes the callbacks by unregistering this mixin instance
  @override
  void dispose() {
    CheckoutCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  void onProductCartClicked() async {
    await InAppStoryManager.instance.closeReaders();
  }
}
