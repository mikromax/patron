// lib/models/import_expense_dto.dart
class ImportExpenseDto {
  final int expenseGroup;
  final String expenseName;
  final double amount;
  final int currencyId;
  final String currencyName;
  final double exchangeRate;
  final double distributedAmount;
  final double remainingAmount;

  ImportExpenseDto({
    required this.expenseGroup,
    required this.expenseName,
    required this.amount,
    required this.currencyId,
    required this.currencyName,
    required this.exchangeRate,
    required this.distributedAmount,
    required this.remainingAmount,
  });

  factory ImportExpenseDto.fromJson(Map<String, dynamic> json) {
    return ImportExpenseDto(
      expenseGroup: (json['expenseGroup'] as num? ?? 0).toInt(),
      expenseName: json['expenseName'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      currencyId: (json['currencyId'] as num? ?? 0).toInt(),
      currencyName: json['currencyName'] as String? ?? '',
      exchangeRate: (json['exchangeRate'] as num? ?? 0).toDouble(),
      distributedAmount: (json['distributedAmount'] as num? ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] as num? ?? 0).toDouble(),
    );
  }
}