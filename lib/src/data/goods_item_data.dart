import 'package:meta/meta.dart';

import '../pigeon_generated.g.dart' show GoodsItemDataDto;

final class GoodsItemData {
  const GoodsItemData({
    required this.sku,
    this.title,
    this.description,
    this.image,
    this.price,
    this.oldPrice,
  });

  final String sku;

  final String? title;

  final String? description;

  final String? image;

  final String? price;

  final String? oldPrice;

  @protected
  GoodsItemDataDto toDto() {
    return GoodsItemDataDto(
      sku: sku,
      title: title,
      description: description,
      image: image,
      oldPrice: oldPrice,
      price: price,
    );
  }
}
