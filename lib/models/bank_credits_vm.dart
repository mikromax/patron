// lib/models/bank_credits_vm.dart
class BankCreditsVM {
  final String bankCode;
  final String creditCode;
  final String currency;
  final double amountOriginal;
  final double amountTl;

  BankCreditsVM({
    required this.bankCode,
    required this.creditCode,
    required this.currency,
    required this.amountOriginal,
    required this.amountTl,
  });

  factory BankCreditsVM.fromJson(Map<String, dynamic> json) {
    return BankCreditsVM(
      bankCode: json['bankCode'] as String? ?? '',
      creditCode: json['creditCode'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      amountOriginal: (json['amount_original'] as num? ?? 0).toDouble(),
      amountTl: (json['amount_tl'] as num? ?? 0).toDouble(),
    );
  }
}