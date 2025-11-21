import 'price_unit_type.dart';
import 'reference_price_scope_type.dart';

class CreateReferencePriceDto {
  final String hsCodeId;
  final double price;
  final String currencyId;
  final PriceUnitType priceUnitType;
  final DateTime startDate;
  final ReferencePriceScopeType scopeType;
  final List<String> countryIds;

  CreateReferencePriceDto({
    required this.hsCodeId,
    required this.price,
    required this.currencyId,
    required this.priceUnitType,
    required this.startDate,
    required this.scopeType,
    required this.countryIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'HsCodeId': hsCodeId,
      'Price': price,
      'CurrencyId': currencyId,
      'PriceUnitType': priceUnitType.value,
      'StartDate': startDate.toIso8601String(),
      'ScopeType': scopeType.value,
      'CountryIds': countryIds,
    };
  }
}