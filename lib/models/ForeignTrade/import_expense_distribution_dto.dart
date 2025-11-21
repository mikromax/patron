// lib/models/import_expense_distribution_dto.dart
// Miras aldığı sınıf
import 'HsCode/hs_code_summary_dto.dart';
class ImportExpenseDistributionDto {
  // Miras alınan alanlar (ImportItemDto'dan)
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
  final HsCodeSummaryDto? hsCode; // Nullable
  
  // Bu sınıfa özel alanlar
  final int expenseGroup;
  final double distributedAmount;
  final double calculatedVatAmount;
  final int dCurrencyId;
  final double originalAmount;
  ImportExpenseDistributionDto({
    required this.itemCode,
    required this.itemName,
    required this.unit,
    required this.quantity,
    required this.weight,
    required this.volume,
    required this.itemAmount,
    required this.currencyId,
    required this.currencyName,
    required this.exchangeRate,
    this.hsCode,
    required this.expenseGroup,
    required this.distributedAmount,
    required this.calculatedVatAmount,
    required this.warehouseId,
    required this.dCurrencyId,
    required this.originalAmount,
  });

  factory ImportExpenseDistributionDto.fromJson(Map<String, dynamic> json) {
    return ImportExpenseDistributionDto(
      // JSON'un tamamını ImportItemDto.fromJson'a göndererek
      // miras alınan alanları dolduruyoruz
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
      hsCode: json['hsCode'] != null
          ? HsCodeSummaryDto.fromJson(json['hsCode'] as Map<String, dynamic>)
          : null,
      
      // Bu sınıfa özel alanları dolduruyoruz
      expenseGroup: (json['expenseGroup'] as num? ?? 0).toInt(),
      distributedAmount: (json['distributedAmount'] as num? ?? 0).toDouble(),
      calculatedVatAmount: (json['calculatedVatAmount'] as num? ?? 0).toDouble(),
      warehouseId: (json['warehouseId'] as num? ?? 0).toInt(),
      dCurrencyId: (json['dCurrencyId'] as num? ?? 0).toInt(),
      originalAmount: (json['originalAmount'] as num? ?? 0).toDouble(),

    );
  }
}