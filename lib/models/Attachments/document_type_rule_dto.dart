// lib/models/Attachments/document_type_rule_dto.dart
import 'package:uuid/uuid.dart';
import 'required_document_dto.dart'; // Birbirine dönüştürmek için

class DocumentTypeRuleDto {
  String id;
  String entityType;
  String documentTypeId;
  String displayName;
  bool isMandatory;
  bool isPassive;
  int attachmentsCount;

  DocumentTypeRuleDto({
    required this.id,
    required this.entityType,
    required this.documentTypeId,
    required this.displayName,
    required this.isMandatory,
    required this.isPassive,
    required this.attachmentsCount,
  });

  // "Ekle" popup'ından yeni bir nesne oluşturmak için
  factory DocumentTypeRuleDto.createNew({
    required String entityType,
    required String documentTypeId,
    required String displayName,
    required bool isMandatory,
    required bool isPassive,
    required int attachmentsCount,
  }) {
    return DocumentTypeRuleDto(
      id: Uuid().v4(), // Yeni bir Guid oluştur
      entityType: entityType,
      documentTypeId: documentTypeId,
      displayName: displayName,
      isMandatory: isMandatory,
      isPassive: isPassive,
      attachmentsCount:  attachmentsCount,
    );
  }

  // "Düzenle" popup'ından mevcut bir nesneyi güncellemek için
  factory DocumentTypeRuleDto.fromExisting(RequiredDocumentDto existingRule, String entityType) {
    return DocumentTypeRuleDto(
      id: existingRule.id, // Mevcut Guid'i kullan
      entityType: entityType,
      documentTypeId: existingRule.documentTypeId,
      displayName: existingRule.displayName,
      isMandatory: existingRule.isMandatory,
      isPassive: existingRule.isPassive,
      attachmentsCount: existingRule.attachmentsCount,
    );
  }

  // API'ye göndermek için JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'entityType': entityType,
      'documentTypeId': documentTypeId,
      'displayName': displayName,
      'isMandatory': isMandatory,
      'IsPassive': isPassive,
      'attachmensCount':attachmentsCount,
    };
  }
}