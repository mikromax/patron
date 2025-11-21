// lib/models/create_user_menu_dto.dart
class CreateUserMenuDto {
  final int programNo;
  final String displayName;
  final String path;
  final String icon;
  final int sortOrder;

  CreateUserMenuDto({
    required this.programNo,
    required this.displayName,
    required this.path,
    required this.icon,
    required this.sortOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'ProgramNo': programNo,
      'DisplayName': displayName,
      'Path': path,
      'Icon': icon,
      'SortOrder': sortOrder,
    };
  }
}