// lib/models/Attachments/entity_type_dto.dart
class EntityTypeDto {
  final String entityName;
  final String sourceContext;

  EntityTypeDto({
    required this.entityName,
    required this.sourceContext,
  });

  factory EntityTypeDto.fromJson(Map<String, dynamic> json) {
    return EntityTypeDto(
      entityName: json['entityName'] as String? ?? '',
      sourceContext: json['sourceContext'] as String? ?? '',
    );
  }

  // Dropdown'da güzel görünmesi için bir helper
  String get display => '$entityName (${sourceContext.toUpperCase()})';
}