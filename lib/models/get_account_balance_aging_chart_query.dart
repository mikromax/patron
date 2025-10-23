// lib/models/get_account_balance_aging_chart_query.dart
class GetAccountBalanceAgingChartQuery {
  final String accountCode;

  GetAccountBalanceAgingChartQuery({required this.accountCode});

  Map<String, String> toQueryParameters() {
    return {
      'accountCode': accountCode,
    };
  }
}