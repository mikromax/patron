// lib/models/Attachments/required_document_dto.dart
class RequiredDocumentDto {
  String id; // Bu ID'yi bir önceki adımdaki API'den alıyoruz (documentTypeId değil)
  String documentTypeId;
  String displayName;
  bool isMandatory;
  bool isPassive;
  int attachmentsCount; // YENİ EKLENEN ALAN

  RequiredDocumentDto({
    required this.id, // Bu, kuralın Guid Id'sidir
    required this.documentTypeId,
    required this.displayName,
    required this.isMandatory,
    required this.isPassive,
    required this.attachmentsCount, // YENİ EKLENEN ALAN
  });

  factory RequiredDocumentDto.fromJson(Map<String, dynamic> json) {
    return RequiredDocumentDto(
      id: json['id'] as String? ?? '', // DTO'nuzda 'Id' alanı olduğunu varsayıyorum
      documentTypeId: json['documentTypeId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      isMandatory: json['isMandatory'] as bool? ?? false,
      isPassive: json['isPassive'] as bool? ?? false,
      attachmentsCount: (json['attachmentsCount'] as num? ?? 0).toInt(), // YENİ EKLENEN ALAN
    );
  }

  // "Ekle" ve "Düzenle" adımlarında API'ye geri göndermek için
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentTypeId': documentTypeId,
      'displayName': displayName,
      'isMandatory': isMandatory,
      'isPassive': isPassive,
      'attachmentsCount': attachmentsCount,
    };
  }
}