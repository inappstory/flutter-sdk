import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/checkout_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/CheckoutGenerated.g.kt',
  kotlinOptions: KotlinOptions(includeErrorClass: false),
  swiftOut: 'ios/Classes/CheckoutGenerated.g.swift',
  swiftOptions: SwiftOptions(includeErrorClass: false),
))
// BannerPlaceManagerHostApi

@FlutterApi()
abstract class CheckoutManagerCallbackFlutterApi {
  @async
  ProductCart onProductCartUpdate(ProductCartOffer offer);

  @async
  ProductCart getProductCartState();
}

@FlutterApi()
abstract class CheckoutCallbackFlutterApi {
  void onProductCartClicked();
}

class ProductCartOffer {
  ProductCartOffer({
    required this.offerId,
    required this.name,
    required this.imageUrls,
    required this.quantity,
    required this.availability,
    this.groupId,
    this.description,
    this.url,
    this.coverUrl,
    this.currency,
    this.price,
    this.oldPrice,
    this.adult,
    this.size,
    this.color,
  });

  String offerId; // product ID
  String? groupId; // product group ID
  String name; // product name
  String? description; // product description
  String? url; // link to external resource for product
  String? coverUrl; // cover image address
  List<String> imageUrls; // list of addresses for product images
  String? currency; // currency in which the product is priced
  String? price; // current product price (after discounts)
  String? oldPrice; // old product price
  bool? adult; // whether the product has age restrictions
  int availability; // product availability
  String? size; // product size
  String? color; // product color
  int quantity; // quantity of the product in the cart
}

class ProductCart {
  List<ProductCartOffer> offers;
  String price;
  String? oldPrice;
  String priceCurrency;

  ProductCart({
    required this.offers,
    required this.price,
    required this.priceCurrency,
    this.oldPrice,
  });
}
