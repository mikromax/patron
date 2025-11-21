// lib/models/pending_approval_line_dto.dart

class PendingApprovalLineDto {
  final String lineId;
  final String documentNumber;
  final String itemCode;
  final String itemName;
  final String currency;
  final double exchageRate;
  final String itemUnit;
  final double unitPrice;
  final double quantity1;
  final double totalDiscount;
  final double totalExpense;
  final double vat;
  final double otherTax;
  final double amount;
  final String createUserName;
  final DateTime createDate;
  final DateTime deliveryDate;
  final String warehouseName;
  final String projectCode;
  // Diğer tüm alanlar buraya eklenebilir...
  
  // Dinamik "Özel Alanlar"
  final Map<String, dynamic> userDefinedFields;

  PendingApprovalLineDto({
    required this.lineId,
    required this.documentNumber,
    required this.itemCode,
    required this.itemName,
    required this.currency,
    required this.exchageRate,
    required this.itemUnit,
    required this.unitPrice,
    required this.quantity1,
    required this.totalDiscount,
    required this.totalExpense,
    required this.vat,
    required this.otherTax,
    required this.amount,
    required this.createUserName,
    required this.createDate,
    required this.deliveryDate,
    required this.warehouseName,
    required this.projectCode,
    required this.userDefinedFields,
    // ...
  });

  // Dinamik alanlara erişim için 'getField' metodu (Header'daki gibi)
  dynamic getField(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'lineid': return lineId;
      case 'documentnumber': return documentNumber;
      case 'itemcode': return itemCode;
      case 'itemname': return itemName;
      case 'currency': return currency;
      case 'exchagerate': return exchageRate;
      case 'itemunit': return itemUnit;
      case 'unitprice': return unitPrice;
      case 'quantity1': return quantity1;
      case 'totaldiscount': return totalDiscount;
      case 'totalexpense': return totalExpense;
      case 'vat': return vat;
      case 'othertax': return otherTax;
      case 'amount': return amount;
      case 'createusername': return createUserName;
      case 'createdate': return createDate;
      case 'deliverydate': return deliveryDate;
      case 'warehousename': return warehouseName;
      case 'projectcode': return projectCode;
      default:
        // Bilinmeyen bir alan adı gelirse, önce özel alanlarda ara
        if (userDefinedFields.containsKey(fieldName)) {
          return userDefinedFields[fieldName];
        }
        return null;
    }
  }

  factory PendingApprovalLineDto.fromJson(Map<String, dynamic> json) {
    return PendingApprovalLineDto(
      lineId: json['lineId'] as String? ?? '',
      documentNumber: json['documentNumber'] as String? ?? '',
      itemCode: json['itemCode'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      exchageRate: (json['exchageRate'] as num? ?? 0).toDouble(),
      itemUnit: json['itemUnit'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
      quantity1: (json['quantity1'] as num? ?? 0).toDouble(),
      totalDiscount: (json['totalDiscount'] as num? ?? 0).toDouble(),
      totalExpense: (json['totalExpense'] as num? ?? 0).toDouble(),
      vat: (json['vat'] as num? ?? 0).toDouble(),
      otherTax: (json['otherTax'] as num? ?? 0).toDouble(),
      amount: (json['amount'] as num? ?? 0).toDouble(),
      createUserName: json['createUserName'] as String? ?? '',
      createDate: DateTime.parse(json['createDate'] as String),
      deliveryDate: DateTime.parse(json['deliveryDate'] as String),
      warehouseName: json['warehouseName'] as String? ?? '',
      projectCode: json['projectCode'] as String? ?? '',
      userDefinedFields: (json['userDefinedFields'] as Map<String, dynamic>?) ?? {},
      // Diğer tüm alanları buraya ekleyin...
    );
  }
}