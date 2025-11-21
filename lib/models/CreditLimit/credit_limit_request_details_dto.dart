// lib/models/credit_limit_request_details_dto.dart
import 'credit_limit_request_types.dart';

// C#'taki base ve inherited DTO'ları tek bir Dart sınıfında birleştiriyoruz
class CreditLimitRequestDetailsDto {
  // Base fields
  final String id;
  final String documentNumber;
  final String customerCode;
  final double currentLimit;
  final double requestedLimit;
  final DateTime expiryDate;
  final String explanation;
  final CreditLimitRequestTypes requestType;

  // Detail fields
  final String customerName;
  final String requestUserName;
  final DateTime requestDate;
  // public RequestStatus Status { get; set; } // Bu enum'ı vermediğiniz için şimdilik eklemedim

  CreditLimitRequestDetailsDto({
    required this.id,
    required this.documentNumber,
    required this.customerCode,
    required this.currentLimit,
    required this.requestedLimit,
    required this.expiryDate,
    required this.explanation,
    required this.requestType,
    required this.customerName,
    required this.requestUserName,
    required this.requestDate,
  });

  factory CreditLimitRequestDetailsDto.fromJson(Map<String, dynamic> json) {
    return CreditLimitRequestDetailsDto(
      id: json['id'] as String,
      documentNumber: json['documentNumber'] as String,
      customerCode: json['customerCode'] as String,
      currentLimit: (json['currentLimit'] as num).toDouble(),
      requestedLimit: (json['requestedLimit'] as num).toDouble(),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      explanation: json['explanation'] as String,
      requestType: CreditLimitRequestTypes.fromValue(json['requestType'] as int),
      customerName: json['customerName'] as String,
      requestUserName: json['requestUserName'] as String,
      requestDate: DateTime.parse(json['requestDate'] as String),
    );
  }
}