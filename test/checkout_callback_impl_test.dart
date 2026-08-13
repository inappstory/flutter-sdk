import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/callbacks/ias_checkout_callback_impl.dart';
import 'package:inappstory_plugin/src/generated/checkout_generated.g.dart';

void main() {
  group('$IASCheckoutManagerCallbackImpl', () {
    group('GIVEN no callback', () {
      late IASCheckoutManagerCallbackImpl impl;
      setUp(() {
        impl = IASCheckoutManagerCallbackImpl();
      });

      test('WHEN onProductCartUpdate called THEN throws error string', () async {
        final offer = ProductCartOffer(
          offerId: 'id',
          name: 'name',
          imageUrls: [],
          availability: 1,
          quantity: 1,
        );
        expect(
          () => impl.onProductCartUpdate(offer),
          throwsA('onProductCartUpdate callback not implemented!'),
        );
      });

      test('WHEN getProductCartState called THEN throws error string', () async {
        expect(
          () => impl.getProductCartState(),
          throwsA('getProductCartState callback not implemented!'),
        );
      });
    });

    group('GIVEN callback set', () {
      late IASCheckoutManagerCallbackImpl impl;
      late ProductCart mockCart;

      setUp(() {
        impl = IASCheckoutManagerCallbackImpl();
        mockCart = ProductCart(
          offers: [],
          price: '10',
          priceCurrency: 'USD',
        );

        impl.getProductCartStateCallback = () async => mockCart;
        impl.onProductCartUpdateCallback = (offer) async => mockCart;
      });

      test('WHEN onProductCartUpdate called THEN returns callback result', () async {
        final offer = ProductCartOffer(
          offerId: 'id',
          name: 'name',
          imageUrls: [],
          availability: 1,
          quantity: 1,
        );
        final result = await impl.onProductCartUpdate(offer);
        expect(result, mockCart);
      });

      test('WHEN getProductCartState called THEN returns callback result', () async {
        final result = await impl.getProductCartState();
        expect(result, mockCart);
      });
    });
  });
}
