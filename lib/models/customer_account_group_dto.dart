// lib/models/customer_account_group_dto.dart
class CustomerAccountGroupDto {
  final int groupNo;
  final int currencyId;
  final String currencySymbol;

  CustomerAccountGroupDto({
    required this.groupNo,
    required this.currencyId,
    required this.currencySymbol,
  });

  factory CustomerAccountGroupDto.fromJson(Map<String, dynamic> json) {
    return CustomerAccountGroupDto(
      groupNo: json['groupNo'] as int,
      currencyId: json['currencyId'] as int,
      currencySymbol: json['currencySymbol'] as String,
    );
  }
}