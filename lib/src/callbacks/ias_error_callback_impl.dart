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
  Future<void> sessionError() async => callback?.sessionError?.call();

  @override
  Future<void> noConnection() async => callback?.noConnection?.call();
}
