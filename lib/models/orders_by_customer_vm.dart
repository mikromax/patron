// lib/models/orders_by_customer_vm.dart
class OrdersByCustomerVM {
  final int orderType;
  final DateTime orderDate;
  final String code;
  final String name;
  final double quantity;
  final String unit;
  final double amount;
  final String currency;
  final bool isApproved;
  final String orderId;

  OrdersByCustomerVM({
    required this.orderType,
    required this.orderDate,
    required this.code,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.amount,
    required this.currency,
    required this.isApproved,
    required this.orderId,
  });
String get orderTypeText {
    switch (orderType) {
      case 0:
        return 'Satış';
      case 1:
        return 'Satın Alma';
      default:
        return 'Bilinmiyor'; // Beklenmedik bir değere karşı önlem
    }
  }
  factory OrdersByCustomerVM.fromJson(Map<String, dynamic> json) {
    return OrdersByCustomerVM(
      orderType: json['orderType'] as int,
      orderDate: DateTime.parse(json['orderDate'] as String),
      code: json['code'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      isApproved: json['isApproved'] as bool,
      orderId: json['orderId'] as String,
    );
  }
}