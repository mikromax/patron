// lib/models/document_sequence_type.dart
enum DocumentSequenceType {
  CreditLimitRequest(0),
  PurchaseRequest(1);

  final int value;
  const DocumentSequenceType(this.value);
}