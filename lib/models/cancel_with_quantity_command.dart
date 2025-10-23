// lib/models/cancel_with_quantity_command.dart
import 'order_line_cancel_dto.dart';

class CancelWithQuantityCommand {
  final String reasonCode;
  final String comment;
  final List<OrderLineCancelDto> orderLines;

  CancelWithQuantityCommand({
    required this.reasonCode,
    required this.comment,
    required this.orderLines,
  });

  Map<String, dynamic> toJson() {
    return {
      'ReasonCode': reasonCode,
      'Comment': comment,
      // Listeyi JSON'a çevirirken her bir elemanın toJson metodunu çağır
      'OrderLines': orderLines.map((line) => line.toJson()).toList(),
    };
  }
}