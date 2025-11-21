// lib/models/pending_approval_header_dto.dart
class PendingApprovalHeaderDto {
  final DateTime documentDate;
  final String documentNumber;
  final DateTime dueDate;
  final String projectCode;
  final String profitCenter;
  final String customerCode;
  final String customerName;
  final String representetiveCode;
  final String representetiveName;
  final int linesCount;
  final double totalAmount;
  final double totalDiscount;
  final double totalTax;

  // Dinamik alanlara erişim için bir 'getter'
  dynamic getField(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'documentdate': return documentDate;
      case 'documentnumber': return documentNumber;
      case 'duedate': return dueDate;
      case 'projectcode': return projectCode;
      case 'profitcenter': return profitCenter;
      case 'customercode': return customerCode;
      case 'customername': return customerName;
      case 'representetivecode': return representetiveCode;
      case 'representetivename': return representetiveName;
      case 'linescount': return linesCount;
      case 'totalamount': return totalAmount;
      case 'totaldiscount': return totalDiscount;
      case 'totaltax': return totalTax;
      default: return null;
    }
  }

  PendingApprovalHeaderDto({
    required this.documentDate,
    required this.documentNumber,
    required this.dueDate,
    // ... tüm diğer alanlar ...
    required this.projectCode,
    required this.profitCenter,
    required this.customerCode,
    required this.customerName,
    required this.representetiveCode,
    required this.representetiveName,
    required this.linesCount,
    required this.totalAmount,
    required this.totalDiscount,
    required this.totalTax,
  });

  factory PendingApprovalHeaderDto.fromJson(Map<String, dynamic> json) {
    return PendingApprovalHeaderDto(
      documentDate: DateTime.parse(json['documentDate'] as String),
      documentNumber: json['documentNumber'] as String? ?? '',
      dueDate: DateTime.parse(json['dueDate'] as String),
      projectCode: json['projectCode'] as String? ?? '',
      profitCenter: json['profitCenter'] as String? ?? '',
      customerCode: json['customerCode'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      representetiveCode: json['representetiveCode'] as String? ?? '',
      representetiveName: json['representetiveName'] as String? ?? '',
      linesCount: (json['linesCount'] as num? ?? 0).toInt(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      totalDiscount: (json['totalDiscount'] as num? ?? 0).toDouble(),
      totalTax: (json['totalTax'] as num? ?? 0).toDouble(),
    );
  }
}