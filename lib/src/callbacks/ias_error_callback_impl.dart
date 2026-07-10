import '../generated/pigeon_generated.g.dart';

class IASErrorCallback {
  const IASErrorCallback({
    this.sessionError,
    this.noConnection,
  });

  final void Function()? sessionError;
  final void Function()? noConnection;
}

class ErrorCallbackFlutterApiImpl implements ErrorCallbackFlutterApi {
  IASErrorCallback? callback;

  @override
  void sessionError() => callback?.sessionError?.call();

  @override
  void noConnection() => callback?.noConnection?.call();
}
