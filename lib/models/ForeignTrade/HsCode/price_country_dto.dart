class PriceCountryDto {
  final String countryId;
  final String countryCode;
  final String countryName;

  PriceCountryDto({
    required this.countryId,
    required this.countryCode,
    required this.countryName,
  });

  factory PriceCountryDto.fromJson(Map<String, dynamic> json) {
    return PriceCountryDto(
      countryId: json['countryId'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      countryName: json['countryName'] as String? ?? '',
    );
  }
}