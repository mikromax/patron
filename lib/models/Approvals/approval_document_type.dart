// lib/models/approval_document_type.dart
enum ApprovalDocumentType {
  SalesOrder(0),
  PurchaseOrder(1),
  Quote(2),
  PurchaseRequest(3);

  final int value;
  const ApprovalDocumentType(this.value);

  // ProgramNo'dan bu enum'ı bulan bir helper
  factory ApprovalDocumentType.fromProgramNo(int? programNo) {
    switch (programNo) {
      case 2101: return ApprovalDocumentType.SalesOrder;
      case 2102: return ApprovalDocumentType.Quote;
      case 3101: return ApprovalDocumentType.PurchaseOrder;
      case 3102: return ApprovalDocumentType.PurchaseRequest;
      default: throw Exception('Bilinmeyen ProgramNo: $programNo');
    }
  }
}