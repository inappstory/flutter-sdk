import 'data/observable.dart';
import 'generated/pigeon_generated.g.dart' show ErrorCallbackFlutterApi;

class ObservableErrorCallbackFlutterApi
    extends Observable<ErrorCallbackFlutterApi>
    implements ErrorCallbackFlutterApi {
  @override
  void addObserver(ErrorCallbackFlutterApi observer) {
    if (observers.isEmpty) ErrorCallbackFlutterApi.setUp(this);

    super.addObserver(observer);
  }

  @override
  void removeObserver(ErrorCallbackFlutterApi observer) {
    super.removeObserver(observer);

    if (observers.isEmpty) ErrorCallbackFlutterApi.setUp(null);
  }

  @override
  void cacheError() {
    for (var it in observers) {
      it.cacheError();
    }
  }

  @override
  void emptyLinkError() {
    for (var it in observers) {
      it.emptyLinkError();
    }
  }

  @override
  void loadListError(String feed) {
    for (var it in observers) {
      it.loadListError(feed);
    }
  }

  @override
  void noConnection() {
    for (var it in observers) {
      it.noConnection();
    }
  }

  @override
  void sessionError() {
    for (var it in observers) {
      it.sessionError();
    }
  }
}
