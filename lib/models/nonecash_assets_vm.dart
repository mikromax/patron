// lib/models/nonecash_assets_vm.dart
class NonecashAssetsVM {
  final String doctype;
  final int doccount;
  final double amount;
  final String position;

  NonecashAssetsVM({
    required this.doctype,
    required this.doccount,
    required this.amount,
    required this.position,
  });

  factory NonecashAssetsVM.fromJson(Map<String, dynamic> json) {
    return NonecashAssetsVM(
      doctype: json['doctype'] as String? ?? '',
      doccount: json['doccount'] as int? ?? 0,
      amount: (json['amount'] as num? ?? 0).toDouble(),
      position: json['position'] as String? ?? '',
    );
  }
}