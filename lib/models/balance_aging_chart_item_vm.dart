// lib/models/balance_aging_chart_item_vm.dart
class BalanceAgingChartItemVM {
  final String period;
  final double amount;
  final DateTime dueDate;

  BalanceAgingChartItemVM({
    required this.period,
    required this.amount,
    required this.dueDate,
  });

  factory BalanceAgingChartItemVM.fromJson(Map<String, dynamic> json) {
    return BalanceAgingChartItemVM(
      period: json['period'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
    );
  }
}