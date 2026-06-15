import '../generated/pigeon_generated.g.dart'
    show CallToActionCallbackFlutterApi, ClickActionDto, SlideDataDto;

typedef CallToActionImpl = void Function(
    SlideDataDto? slideData, String? url, ClickActionDto? clickAction);

class CallToActionCallbackImpl implements CallToActionCallbackFlutterApi {
  final List<CallToActionImpl> _callbacks = [];

  void addCallback(CallToActionImpl callback) {
    if (_callbacks.isNotEmpty && _callbacks.contains(callback)) {
      return;
    }
    _callbacks.add(callback);
  }

  void removeCallback(CallToActionImpl callback) {
    if (_callbacks.isEmpty) {
      return;
    }
    _callbacks.remove(callback);
  }

  @override
  void callToAction(
      SlideDataDto? slideData, String? url, ClickActionDto? clickAction) {
    for (final callback in _callbacks) {
      callback.call(slideData, url, clickAction);
    }
  }
}
