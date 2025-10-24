// lib/models/get_item_prices_query.dart
class GetItemPricesQuery {
  final String itemCode;

  GetItemPricesQuery({required this.itemCode});

  Map<String, String> toQueryParameters() {
    return {
      'itemCode': itemCode,
    };
  }
}