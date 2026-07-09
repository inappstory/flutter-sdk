import '../generated/pigeon_generated.g.dart';

class IASErrorCallback {
  const IASErrorCallback({
    this.loadListError,
    this.cacheError,
    this.emptyLinkError,
    this.sessionError,
    this.noConnection,
  });

  final void Function(String? feed)? loadListError;
  final void Function()? cacheError;
  final void Function()? emptyLinkError;
  final void Function()? sessionError;
  final void Function()? noConnection;
}

class ErrorCallbackFlutterApiImpl implements ErrorCallbackFlutterApi {
  IASErrorCallback? callback;

  @override
  void loadListError(String? feed) => callback?.loadListError?.call(feed);

  @override
  void cacheError() => callback?.cacheError?.call();

  @override
  void emptyLinkError() => callback?.emptyLinkError?.call();

  @override
  void sessionError() => callback?.sessionError?.call();

  @override
  void noConnection() => callback?.noConnection?.call();
}
