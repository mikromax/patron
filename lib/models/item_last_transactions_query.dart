// lib/models/item_last_transactions_query.dart
class ItemLastTransactionsQuery {
  final String itemCode;
  final int transactionType; // 0 for entry, 1 for exit

  ItemLastTransactionsQuery({required this.itemCode, required this.transactionType});

  Map<String, String> toQueryParameters() {
    return {
      'itemCode': itemCode,
      'transactionType': transactionType.toString(),
    };
  }
}