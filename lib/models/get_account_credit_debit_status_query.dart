// lib/models/get_account_credit_debit_status_query.dart
class GetAccountCreditDebitStatusQuery {
  final bool isDebit;

  GetAccountCreditDebitStatusQuery({required this.isDebit});

  Map<String, String> toQueryParameters() {
    return {
      'isDebit': isDebit.toString(),
    };
  }
}