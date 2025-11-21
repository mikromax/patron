import 'approval_document_type.dart';

class ApproveDocumentDto {
  final ApprovalDocumentType documentType;
  final String documentNumber;

  ApproveDocumentDto({
    required this.documentType,
    required this.documentNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      // C#'taki property adları (PascalCase) ile eşleşiyor
      'DocumentType': documentType.value, // Enum'ın int değerini gönder
      'DocumentNumber': documentNumber,
    };
  }
}