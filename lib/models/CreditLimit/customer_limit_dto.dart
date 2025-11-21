// lib/models/customer_limit_dto.dart
class CustomerLimitDto {
  final String contentName;
  final String descriptionName;
  final double totalAmount;

  CustomerLimitDto({
    required this.contentName,
    required this.descriptionName,
    required this.totalAmount,
  });

  factory CustomerLimitDto.fromJson(Map<String, dynamic> json) {
    // C# property'leri (PascalCase) JSON'da (camelCase) olur
    return CustomerLimitDto(
      contentName: json['contentName'] as String? ?? '',
      descriptionName: json['descriptionName'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
    );
  }
}