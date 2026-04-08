import '../generated/pigeon_generated.g.dart'
    show CallToActionCallbackFlutterApi, ClickActionDto, SlideDataDto;

typedef CallToActionImpl = void Function(
    SlideDataDto? slideData, String? url, ClickActionDto? clickAction);

class CallToActionCallbackImpl implements CallToActionCallbackFlutterApi {
  CallToActionImpl? _callback;

  set callback(CallToActionImpl? value) {
    _callback = value;
  }

  @override
  void callToAction(
      SlideDataDto? slideData, String? url, ClickActionDto? clickAction) {
    _callback?.call(slideData, url, clickAction);
  }
}
