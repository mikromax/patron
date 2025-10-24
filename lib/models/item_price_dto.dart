// lib/models/item_price_dto.dart
class ItemPriceDto {
  final int priceListNo;
  final double price;
  final int currencyNo;
  final String currencyCode;

  ItemPriceDto({
    required this.priceListNo,
    required this.price,
    required this.currencyNo,
    required this.currencyCode,
  });

  factory ItemPriceDto.fromJson(Map<String, dynamic> json) {
    return ItemPriceDto(
      priceListNo: json['priceListNo'] as int? ?? 0,
      price: (json['price'] as num? ?? 0).toDouble(),
      currencyNo: json['currencyNo'] as int? ?? 0,
      currencyCode: json['currencyCode'] as String? ?? '',
    );
  }
}