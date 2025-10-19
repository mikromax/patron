// lib/models/account_credit_debit_status_dto.dart
class AccountCreditDebitStatusDto {
  final String code;
  final String definition;
  final String currency;
  final double amountOriginal;
  final double amountTl;
  final int grup;
  final String region;
  final String suppliergroup;
  final String sector;
  final String representative;

  AccountCreditDebitStatusDto({
    required this.code,
    required this.definition,
    required this.currency,
    required this.amountOriginal,
    required this.amountTl,
    required this.grup,
    required this.region,
    required this.suppliergroup,
    required this.sector,
    required this.representative,
  });

  factory AccountCreditDebitStatusDto.fromJson(Map<String, dynamic> json) {
    return AccountCreditDebitStatusDto(
      code: json['code'] as String,
      definition: json['definition'] as String,
      currency: json['currency'] as String,
      amountOriginal: (json['amount_original'] as num).toDouble(),
      amountTl: (json['amount_tl'] as num).toDouble(),
      grup: json['grup'] as int,
      region: json['region'] as String,
      suppliergroup: json['suppliergroup'] as String,
      sector: json['sector'] as String,
      representative: json['representative'] as String,
    );
  }
}