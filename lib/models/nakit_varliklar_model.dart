// lib/models/nakit_varliklar_model.dart

class NakitVarliklar {
  List<Detail> details;

  double get totalAmountTl => details.fold(0, (sum, item) => sum + item.amountTl);

  NakitVarliklar({required this.details});

  factory NakitVarliklar.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List;
    List<Detail> details = detailsList.map((i) => Detail.fromJson(i)).toList();
    return NakitVarliklar(details: details);
  }
}

class Detail {
  final String definition;
  final String currency;
  final double amountOriginal;
  final double amountTl;

  Detail({
    required this.definition,
    required this.currency,
    required this.amountOriginal,
    required this.amountTl,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      definition: json['definition'],
      currency: json['currency'],
      amountOriginal: json['amount_original'],
      amountTl: json['amount_tl'],
    );
  }
}