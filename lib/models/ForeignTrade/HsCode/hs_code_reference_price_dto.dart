import 'price_country_dto.dart';
import 'price_unit_type.dart';
import 'reference_price_scope_type.dart';

class HsCodeReferencePriceDto {
  final String id;
  final String hsCodeId;
  final String firmId;
  final double price;
  final String currencyId;
  final String currencyCode;
  final PriceUnitType priceUnitType;
  final String priceUnitTypeName;
  final DateTime startDate;
  final DateTime? endDate;
  final ReferencePriceScopeType scopeType;
  final String scopeTypeName;
  final List<PriceCountryDto> countryList;

  HsCodeReferencePriceDto({
    required this.id,
    required this.hsCodeId,
    required this.firmId,
    required this.price,
    required this.currencyId,
    required this.currencyCode,
    required this.priceUnitType,
    required this.priceUnitTypeName,
    required this.startDate,
    this.endDate,
    required this.scopeType,
    required this.scopeTypeName,
    required this.countryList,
  });

  factory HsCodeReferencePriceDto.fromJson(Map<String, dynamic> json) {
    var countries = (json['countryList'] as List<dynamic>?)
        ?.map((item) => PriceCountryDto.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];
        
    return HsCodeReferencePriceDto(
      id: json['id'] as String,
      hsCodeId: json['hsCodeId'] as String,
      firmId: json['firmId'] as String,
      price: (json['price'] as num).toDouble(), // C#'ta decimal, Dart'ta double
      currencyId: json['currencyId'] as String,
      currencyCode: json['currencyCode'] as String,
      priceUnitType: PriceUnitType.fromValue(json['priceUnitType'] as int),
      priceUnitTypeName: json['priceUnitTypeName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      scopeType: ReferencePriceScopeType.fromValue(json['scopeType'] as int),
      scopeTypeName: json['scopeTypeName'] as String,
      countryList: countries,
    );
  }
}