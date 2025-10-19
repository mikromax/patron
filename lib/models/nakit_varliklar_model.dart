class NakitVarliklar {
  List<Detail> details;

  double get totalAmountTl => details.fold(0.0, (sum, item) => sum + item.amountTl);

  NakitVarliklar({required this.details});

  factory NakitVarliklar.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List;
    List<Detail> details = detailsList.map((i) => Detail.fromJson(i)).toList();
    return NakitVarliklar(details: details);
  }
}

class Detail {
  final String code; // YENİ EKLENEN ALAN
  final String definition;
  final String currency;
  final double amountOriginal;
  final double amountTl;

  Detail({
    required this.code, // YENİ EKLENEN ALAN
    required this.definition,
    required this.currency,
    required this.amountOriginal,
    required this.amountTl,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      code: json['code'] as String, // YENİ EKLENEN ALAN
      definition: json['definition'] as String,
      currency: json['currency'] as String,
      amountOriginal: (json['amount_original'] as num).toDouble(),
      amountTl: (json['amount_tl'] as num).toDouble(),
    );
  }
}