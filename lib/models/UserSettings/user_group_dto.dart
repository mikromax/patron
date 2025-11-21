// lib/models/UserSettings/user_group_dto.dart
class UserGroupDto {
  final String id;
  final String code;
  final String description;
  final bool isPassive;

  UserGroupDto({
    required this.id,
    required this.code,
    required this.description,
    required this.isPassive,
  });

  factory UserGroupDto.fromJson(Map<String, dynamic> json) {
    return UserGroupDto(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isPassive: json['isPassive'] as bool? ?? false,
    );
  }
  
  // Dropdown'da görünmesi için
  String get display => '$code - $description';
}