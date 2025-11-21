// lib/models/UserSettings/role_users_dto.dart
class RoleUsersDto {
  final String roleId;
  final List<String> userIds;

  RoleUsersDto({
    required this.roleId,
    required this.userIds,
  });

  // API List<string> beklediği için doğrudan listeyi dönmek yerine
  // bu DTO'yu değil, direkt listeyi göndereceğiz.
  // Ancak yapısal bütünlük için bu sınıfı tutabiliriz.
}