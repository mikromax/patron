// lib/models/order_line_cancel_dto.dart
class OrderLineCancelDto {
  final String lineId;
  final double quantity;

  OrderLineCancelDto({required this.lineId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'LineId': lineId,
      'Quantity': quantity,
    };
  }
}