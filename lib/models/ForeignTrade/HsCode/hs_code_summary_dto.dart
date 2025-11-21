// lib/models/hs_code_summary_dto.dart
import 'hs_code_reference_price_dto.dart';

class HsCodeSummaryDto {
  final String id;
  final String code;
  final String description;
  final HsCodeReferencePriceDto? referencePriceDetails;

  HsCodeSummaryDto({
    required this.id,
    required this.code,
    required this.description,
    this.referencePriceDetails,
  });

  factory HsCodeSummaryDto.fromJson(Map<String, dynamic> json) {
    return HsCodeSummaryDto(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      referencePriceDetails: json['referencePriceDetails'] != null
          ? HsCodeReferencePriceDto.fromJson(json['referencePriceDetails'] as Map<String, dynamic>)
          : null,
    );
  }
}