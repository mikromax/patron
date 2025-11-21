// lib/models/field_hint_dto.dart
class FieldHintDto {
  final String fieldName;
  final String displayName;
  final int sortOrder;

  FieldHintDto({
    required this.fieldName,
    required this.displayName,
    required this.sortOrder,
  });

  factory FieldHintDto.fromJson(Map<String, dynamic> json) {
    return FieldHintDto(
      fieldName: json['fieldName'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}