import '../generated/checkout_generated.g.dart';

typedef OnProductCartUpdateCallbackImpl = Future<ProductCart> Function(
    ProductCartOffer offer);

typedef GetProductCartStateCallbackImpl = Future<ProductCart> Function();

class IASCheckoutManagerCallbackImpl
    implements CheckoutManagerCallbackFlutterApi {
  GetProductCartStateCallbackImpl? _getCartStateCallback;

  set getProductCartStateCallback(GetProductCartStateCallbackImpl value) {
    _getCartStateCallback = value;
  }

  OnProductCartUpdateCallbackImpl? _onProductCartUpdateCallback;

  set onProductCartUpdateCallback(OnProductCartUpdateCallbackImpl value) {
    _onProductCartUpdateCallback = value;
  }

  @override
  Future<ProductCart> onProductCartUpdate(ProductCartOffer offer) async {
    if (_onProductCartUpdateCallback == null) {
      return Future.error('onProductCartUpdate callback not implemented!');
    }

    final data = await _onProductCartUpdateCallback!.call(offer);
    return data;
  }

  @override
  Future<ProductCart> getProductCartState() async {
    if (_getCartStateCallback == null) {
      return Future.error('getProductCartState callback not implemented!');
    }

    final data = await _getCartStateCallback!.call();
    return data;
  }
}
