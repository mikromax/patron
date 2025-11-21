// lib/models/create_credit_limit_request_dto.dart
import 'credit_limit_request_types.dart';

class CreateCreditLimitRequestDto {
  final String id;
  final String documentNumber;
  final String customerCode;
  final double currentLimit;
  final double requestedLimit;
  final DateTime expiryDate;
  final String explanation;
  final CreditLimitRequestTypes requestType;

  CreateCreditLimitRequestDto({
    required this.id,
    required this.documentNumber,
    required this.customerCode,
    required this.currentLimit,
    required this.requestedLimit,
    required this.expiryDate,
    required this.explanation,
    required this.requestType,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'DocumentNumber': documentNumber,
      'CustomerCode': customerCode,
      'CurrentLimit': currentLimit,
      'RequestedLimit': requestedLimit,
      'ExpiryDate': expiryDate.toIso8601String(),
      'Explanation': explanation,
      'RequestType': requestType.value,
    };
  }
}