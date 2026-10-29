import 'package:meta/meta.dart';

import '../generated/appearance_manager.g.dart' show GoodsItemDataDto;

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

  @internal
  factory GoodsItemData.fromDto(GoodsItemDataDto dto) {
    return GoodsItemData(
      sku: dto.sku ?? '',
      title: dto.title,
      description: dto.productDescription,
      image: dto.image,
      price: dto.price,
      oldPrice: dto.oldPrice,
    );
  }

  @internal
  GoodsItemDataDto toDto() {
    return GoodsItemDataDto(
      sku: sku,
      title: title,
      productDescription: description,
      image: image,
      oldPrice: oldPrice,
      price: price,
    );
  }
}
