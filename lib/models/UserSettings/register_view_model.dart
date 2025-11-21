// lib/models/UserSettings/register_view_model.dart
import 'package:uuid/uuid.dart';
import 'user_type_enum.dart';

class RegisterViewModel {
  String? userId; // Yeni kayıtta null olabilir veya biz oluşturabiliriz
  String userName;
  String email;
  String password;
  String userGroupId; // Guid string olarak
  String description;
  bool isPassive;
  UserType type;
  Map<String, String> claims;

  RegisterViewModel({
    this.userId,
    required this.userName,
    required this.email,
    required this.password,
    required this.userGroupId,
    required this.description,
    required this.isPassive,
    required this.type,
    this.claims = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId ?? const Uuid().v4(), // ID yoksa oluştur
      'UserName': userName,
      'Email': email,
      'Password': password,
      'UserGroupId': userGroupId,
      'Description': description,
      'IsPassive': isPassive,
      'Type': type.value,
      'Claims': claims,
    };
  }
}