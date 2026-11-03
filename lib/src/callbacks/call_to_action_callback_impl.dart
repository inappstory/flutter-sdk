import '../data/story_data.dart';
import '../generated/pigeon_generated.g.dart'
    show CallToActionCallbackFlutterApi, ClickActionDto, SlideDataDto;

typedef CallToActionImpl = void Function(
    SlideData? slideData, String? url, ClickAction? clickAction);

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
  Future<void> callToAction(
      SlideDataDto? slideData, String? url, ClickActionDto? clickAction) async {
    final domainSlideData =
        slideData == null ? null : SlideData.fromDto(slideData);
    final domainClickAction =
        clickAction == null ? null : ClickAction.fromDto(clickAction);
    for (final callback in _callbacks) {
      callback.call(domainSlideData, url, domainClickAction);
    }
  }
}
