import 'mikro_user_type.dart';

class SetUserMikroDetailsCommand {
  final String tokenUserId;
  final int mikroUserNo;
  final String userName;
  final MikroUserType userType;
  final String plasiyerKodu;
  final String cariKodu;

  SetUserMikroDetailsCommand({
    required this.tokenUserId,
    required this.mikroUserNo,
    required this.userName,
    required this.userType,
    required this.plasiyerKodu,
    required this.cariKodu,
  });

  Map<String, dynamic> toJson() {
    return {
      'TokenUserId': tokenUserId,
      'MikroUserNo': mikroUserNo,
      'UserName': userName,
      'UserType': userType.value, // Enum'ı 'int' değere çevir
      'PlasiyerKodu': plasiyerKodu,
      'CariKodu': cariKodu,
    };
  }
}