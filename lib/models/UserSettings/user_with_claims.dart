// lib/models/UserSettings/user_with_claims.dart
class UserWithClaims {
  final String userId;
  final String userName;
  final String? email;
  final String? description;
  final bool isPassive;

  UserWithClaims({
    required this.userId,
    required this.userName,
    this.email,
    this.description,
    required this.isPassive,
  });

  factory UserWithClaims.fromJson(Map<String, dynamic> json) {
    return UserWithClaims(
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String?,
      description: json['description'] as String?,
      isPassive: json['isPassive'] as bool? ?? false,
    );
  }
}