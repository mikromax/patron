import 'approval_document_type.dart';

class CancelDocumentDto {
  final ApprovalDocumentType documentType;
  final String documentNumber;
  final String cancelReason;
  final String comment;

  CancelDocumentDto({
    required this.documentType,
    required this.documentNumber,
    required this.cancelReason,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      // C#'taki property adları (PascalCase) ile eşleşiyor
      'DocumentType': documentType.value,
      'DocumentNumber': documentNumber,
      'CancelReason': cancelReason,
      'Comment': comment,
    };
  }
}