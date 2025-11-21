// lib/models/user_menu_dto.dart
class UserMenuDto {
  final String id; // Guid'i String olarak almak daha güvenlidir
  final int programNo;
  final String displayName;
  final String path;
  final int sortOrder;
  final String? icon;
  UserMenuDto({
    required this.id,
    required this.programNo,
    required this.displayName,
    required this.path,
    required this.sortOrder,
    this.icon,
  });

  factory UserMenuDto.fromJson(Map<String, dynamic> json) {
    return UserMenuDto(
      id: json['id'] as String,
      programNo: json['programNo'] as int,
      displayName: json['displayName'] as String,
      path: json['path'] as String,
      sortOrder: json['sortOrder'] as int,
      icon: json['icon'] as String?
    );
  }
}