// lib/models/approve_with_quantity_command.dart
import 'order_line_cancel_dto.dart';

class ApproveWithQuantityCommand {
  final String comment;
  final List<OrderLineCancelDto> orderLines;

  ApproveWithQuantityCommand({
    required this.comment,
    required this.orderLines,
  });

  Map<String, dynamic> toJson() {
    return {
      'Comment': comment,
      'OrderLines': orderLines.map((line) => line.toJson()).toList(),
    };
  }
}