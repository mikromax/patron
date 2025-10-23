// lib/models/get_all_orders_by_customer_query.dart
class GetAllOrdersByCustomerQuery {
  final String accountCode;

  GetAllOrdersByCustomerQuery({required this.accountCode});

  Map<String, String> toQueryParameters() {
    return {
      'accountCode': accountCode,
    };
  }
}