// lib/models/item_transaction_dto.dart
class ItemTransactionDto {
  final DateTime transactionDate;
  final String account;
  final String transactionType;
  final String documentType;
  final String wareHouse;
  final double quantity;
  final String unit;

  ItemTransactionDto({
    required this.transactionDate,
    required this.account,
    required this.transactionType,
    required this.documentType,
    required this.wareHouse,
    required this.quantity,
    required this.unit,
  });

  factory ItemTransactionDto.fromJson(Map<String, dynamic> json) {
    return ItemTransactionDto(
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      account: json['account'] as String? ?? '',
      transactionType: json['transactionType'] as String? ?? '',
      documentType: json['documentType'] as String? ?? '',
      wareHouse: json['wareHouse'] as String? ?? '',
      quantity: (json['quantity'] as num? ?? 0).toDouble(),
      unit: json['unit'] as String? ?? '',
    );
  }
}