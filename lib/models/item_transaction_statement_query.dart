// lib/models/item_transaction_statement_query.dart
import 'package:intl/intl.dart';

class ItemTransactionStatementQuery {
  final String itemCode;
  final DateTime startDate;
  final DateTime endDate;

  ItemTransactionStatementQuery({
    required this.itemCode,
    required this.startDate,
    required this.endDate,
  });

  Map<String, String> toQueryParameters() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return {
      'itemCode': itemCode,
      'startDate': formatter.format(startDate),
      'endDate': formatter.format(endDate),
    };
  }
}