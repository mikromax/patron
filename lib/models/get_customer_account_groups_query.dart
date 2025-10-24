// lib/models/get_customer_account_groups_query.dart
class GetCustomerAccountGroupsQuery {
  final String customerCode;

  GetCustomerAccountGroupsQuery({required this.customerCode});

  Map<String, String> toQueryParameters() {
    return {
      'customerCode': customerCode,
    };
  }
}