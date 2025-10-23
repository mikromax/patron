// lib/models/inventory_status_dto.dart
class InventoryStatusDto {
  final String itemCode;
  final String itemName;
  final double quantity;
  final String itemGroup;
  final String warehouse;
  final double amountTl;
  final String brand;

  InventoryStatusDto({
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.itemGroup,
    required this.warehouse,
    required this.amountTl,
    required this.brand,
  });

  // API'nizdeki gerçek alan adları farklıysa, lütfen buradaki 'json['...']'
  // kısımlarını ona göre güncelleyin.
  factory InventoryStatusDto.fromJson(Map<String, dynamic> json) {
    return InventoryStatusDto(
      itemCode: json['itemCode'] as String,
      itemName: json['itemName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      warehouse: json['warehouse'] as String,
      itemGroup: json['itemGroup'] as String,
      amountTl: (json['amount_tl'] as num).toDouble(),
      brand: json['brand'] as String,
    );
  }
}