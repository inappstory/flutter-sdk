import '../generated/checkout_generated.g.dart';

typedef AddToCartCallbackImpl = Future<ProductCart> Function(
    ProductCartOffer offer);

typedef GetCartStateCallbackImpl = Future<ProductCart> Function();

class IasCheckoutCallbackImpl implements CheckoutManagerCallbackFlutterApi {
  GetCartStateCallbackImpl? _getCartStateCallback;

  set getCartStateCallback(GetCartStateCallbackImpl value) {
    _getCartStateCallback = value;
  }

  AddToCartCallbackImpl? _addToCartCallback;

  set addToCartCallback(AddToCartCallbackImpl? value) {
    _addToCartCallback = value;
  }

  @override
  Future<ProductCart> addProductToCart(ProductCartOffer offer) async {
    if (_addToCartCallback == null) {
      return ProductCart(offers: [], price: '', priceCurrency: '');
    }

    final data = await _addToCartCallback!.call(offer);
    return data;
  }

  @override
  Future<ProductCart> getCartState() async {
    if (_getCartStateCallback == null) {
      return ProductCart(offers: [], price: '', priceCurrency: '');
    }

    final data = await _getCartStateCallback!.call();
    return data;
  }
}
