class StatementDetailModel {
  final DateTime transactionDate;
  final String documentSerial;
  final int documentNumber;
  final String documentType;
  final String debitCredit;
  final double amountTl;
  final double amountOriginal;

  StatementDetailModel({
    required this.transactionDate,
    required this.documentSerial,
    required this.documentNumber,
    required this.documentType,
    required this.debitCredit,
    required this.amountTl,
    required this.amountOriginal,
  });

  factory StatementDetailModel.fromJson(Map<String, dynamic> json) {
    return StatementDetailModel(
      // API'den gelen tarih string'ini DateTime nesnesine çeviriyoruz.
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      documentSerial: json['documentSerial'] as String,
      documentNumber: json['documentNumber'] as int,
      documentType: json['documentType'] as String,
      debitCredit: json['debitCredit'] as String,
      amountTl: (json['amount_tl'] as num).toDouble(),
      amountOriginal: (json['amount_original'] as num).toDouble(),
    );
  }
}