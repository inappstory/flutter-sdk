import 'package:meta/meta.dart';

import '../pigeon_generated.g.dart' show GoodsItemDataDto;

final class GoodsItemData {
  const GoodsItemData({
    required this.sku,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.oldPrice,
  });

  final String sku;

  final String title;

  final String description;

  final String image;

  final String price;

  final String oldPrice;

  @protected
  GoodsItemDataDto toDto() {
    return GoodsItemDataDto(
      title: title,
      description: description,
      image: image,
      oldPrice: oldPrice,
      price: price,
      sku: sku,
    );
  }
}
