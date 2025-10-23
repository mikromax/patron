// lib/models/balance_aging_chart_vm.dart
import 'balance_aging_chart_item_vm.dart';

class BalanceAgingChartVM {
  final String currency;
  final double totalAmount;
  final DateTime dueDate;
  final double overdueAmount;
  final DateTime overdueDate;
  final double outstandingAmount;
  final DateTime outstandingDate;
  final List<BalanceAgingChartItemVM> items;

  BalanceAgingChartVM({
    required this.currency,
    required this.totalAmount,
    required this.dueDate,
    required this.overdueAmount,
    required this.overdueDate,
    required this.outstandingAmount,
    required this.outstandingDate,
    required this.items,
  });

  factory BalanceAgingChartVM.fromJson(Map<String, dynamic> json) {
    var itemsFromJson = json['items'] as List<dynamic>? ?? [];
    List<BalanceAgingChartItemVM> itemsList = itemsFromJson
        .map((i) => BalanceAgingChartItemVM.fromJson(i as Map<String, dynamic>))
        .toList();

    return BalanceAgingChartVM(
      currency: json['currency'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      overdueAmount: (json['overdueAmount'] as num? ?? 0).toDouble(),
      overdueDate: DateTime.parse(json['overdueDate'] as String),
      outstandingAmount: (json['outstandingAmount'] as num? ?? 0).toDouble(),
      outstandingDate: DateTime.parse(json['outstandingDate'] as String),
      items: itemsList,
    );
  }
}