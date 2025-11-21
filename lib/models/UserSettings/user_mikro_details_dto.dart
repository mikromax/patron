import 'mikro_user_type.dart';

class UserMikroDetailsDto {
  final String id;
  final String tokenUserId;
  final int mikroUserNo;
  final String userName;
  final MikroUserType userType;
  final String plasiyerKodu;
  final String cariKodu;

  UserMikroDetailsDto({
    required this.id,
    required this.tokenUserId,
    required this.mikroUserNo,
    required this.userName,
    required this.userType,
    required this.plasiyerKodu,
    required this.cariKodu,
  });

  factory UserMikroDetailsDto.fromJson(Map<String, dynamic> json) {
    return UserMikroDetailsDto(
      id: json['id'] as String? ?? '',
      tokenUserId: json['tokenUserId'] as String? ?? '',
      mikroUserNo: (json['mikroUserNo'] as num? ?? 0).toInt(),
      userName: json['userName'] as String? ?? '',
      // Gelen 'int' değeri enum'a çeviriyoruz
      userType: MikroUserType.fromValue(json['userType'] as int? ?? 1), // 1 = Standart
      plasiyerKodu: json['plasiyerKodu'] as String? ?? '',
      cariKodu: json['cariKodu'] as String? ?? '',
    );
  }
}