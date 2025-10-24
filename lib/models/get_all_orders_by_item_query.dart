// lib/models/get_all_orders_by_item_query.dart
class GetAllOrdersByItemQuery {
  final String itemCode;

  GetAllOrdersByItemQuery({required this.itemCode});

  Map<String, String> toQueryParameters() {
    return {
      'itemCode': itemCode,
    };
  }
}