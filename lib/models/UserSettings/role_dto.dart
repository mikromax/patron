// lib/models/UserSettings/role_dto.dart
class RoleDto {
  final String id;
  final String code;
  final String description;
  final bool isPassive;
  final String? customMenuId;
  final String? customMenuName;

  RoleDto({
    required this.id,
    required this.code,
    required this.description,
    required this.isPassive,
    this.customMenuId,
    this.customMenuName,
  });

  factory RoleDto.fromJson(Map<String, dynamic> json) {
    return RoleDto(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isPassive: json['isPassive'] as bool? ?? false,
      customMenuId: json['customMenuId'] as String?,
      customMenuName: json['customMenuName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Code': code,
      'Description': description,
      'IsPassive': isPassive,
      'CustomMenuId': customMenuId,
      'CustomMenuName': customMenuName,
    };
  }
}