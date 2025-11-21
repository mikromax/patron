// lib/models/HsCode/hs_code_tree_node_dto.dart
class HsCodeTreeNodeDto {
  final String id;
  final String? parentId; // String (Guid) veya null
  final String code;
  final String description;

  HsCodeTreeNodeDto({
    required this.id,
    this.parentId,
    required this.code,
    required this.description,
  });

  factory HsCodeTreeNodeDto.fromJson(Map<String, dynamic> json) {
    return HsCodeTreeNodeDto(
      id: json['id'] as String,
      parentId: json['parentId'] as String?, // Null olabilir
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}