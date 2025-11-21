// (Bu DTO'nun Create ile aynı olduğunu varsayarak,
// C#'taki UpdateReferencePriceDto'nun alanlarını da aynı kabul ediyorum)
// Eğer alanlar farklıysa bu sınıfı ona göre güncelleyin.
import 'price_unit_type.dart';
import 'reference_price_scope_type.dart';

class UpdateReferencePriceDto {
  final double price;
  final String currencyId;
  final PriceUnitType priceUnitType;
  final DateTime startDate;
  final ReferencePriceScopeType scopeType;
  final List<String> countryIds;

  UpdateReferencePriceDto({
    required this.price,
    required this.currencyId,
    required this.priceUnitType,
    required this.startDate,
    required this.scopeType,
    required this.countryIds,
  });

  Map<String, dynamic> toJson() {
    return {
      // HsCodeId'yi göndermiyoruz, çünkü URL'de
      'Price': price,
      'CurrencyId': currencyId,
      'PriceUnitType': priceUnitType.value,
      'StartDate': startDate.toIso8601String(),
      'ScopeType': scopeType.value,
      'CountryIds': countryIds,
    };
  }
}