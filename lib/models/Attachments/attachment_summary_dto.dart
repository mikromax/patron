// lib/models/Attachments/attachment_summary_dto.dart
class AttachmentSummaryDto {
  final String id;
  final String documentTypeId;
  final String fileName;
  final int fileSize;

  AttachmentSummaryDto({
    required this.id,
    required this.documentTypeId,
    required this.fileName,
    required this.fileSize,
  });

  factory AttachmentSummaryDto.fromJson(Map<String, dynamic> json) {
    return AttachmentSummaryDto(
      id: json['id'] as String? ?? '',
      documentTypeId: json['documentTypeId'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileSize: (json['fileSize'] as num? ?? 0).toInt(),
    );
  }

  // Dosya boyutunu okunabilir formata (KB, MB) çeviren yardımcı bir getter
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1048576) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / 1048576).toStringAsFixed(1)} MB';
  }
}