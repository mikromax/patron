// lib/models/import_item_dto.dart
import 'HsCode/hs_code_summary_dto.dart';

class ImportItemDto {
  final String itemCode;
  final String itemName;
  final String unit;
  final double quantity;
  final double weight;
  final double volume;
  final double itemAmount;
  final int currencyId;
  final String currencyName;
  final double exchangeRate;
  final int warehouseId; 
  final HsCodeSummaryDto? hsCode;

  ImportItemDto({
    required this.itemCode,
    required this.itemName,
    required this.unit,
    required this.quantity,
    required this.weight,
    required this.volume,
    required this.itemAmount,
    required this.currencyId,
    required this.currencyName,
    required this.warehouseId,
    required this.exchangeRate,
    this.hsCode,
  });

  factory ImportItemDto.fromJson(Map<String, dynamic> json) {
    return ImportItemDto(
      itemCode: json['itemCode'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      quantity: (json['quantity'] as num? ?? 0).toDouble(),
      weight: (json['weight'] as num? ?? 0).toDouble(),
      volume: (json['volume'] as num? ?? 0).toDouble(),
      itemAmount: (json['itemAmount'] as num? ?? 0).toDouble(),
      currencyId: (json['currencyId'] as num? ?? 0).toInt(),
      currencyName: json['currencyName'] as String? ?? '',
      exchangeRate: (json['exchangeRate'] as num? ?? 0).toDouble(),
      warehouseId: (json['warehouseId'] as num? ?? 0).toInt(),
      hsCode: json['hsCode'] != null
          ? HsCodeSummaryDto.fromJson(json['hsCode'] as Map<String, dynamic>)
          : null,
    );
  }
}