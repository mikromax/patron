// lib/models/HsCode/hs_code_detail_dto.dart
class HsCodeDetailDto {
  final String id;
  final String code;
  final String description;
  final String positionCode;
  final String positionName;
  final String phaseCode;
  final String phaseName;

  HsCodeDetailDto({
    required this.id,
    required this.code,
    required this.description,
    required this.positionCode,
    required this.positionName,
    required this.phaseCode,
    required this.phaseName,
  });

  factory HsCodeDetailDto.fromJson(Map<String, dynamic> json) {
    return HsCodeDetailDto(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      positionCode: json['positionCode'] as String? ?? '',
      positionName: json['positionName'] as String? ?? '',
      phaseCode: json['phaseCode'] as String? ?? '',
      phaseName: json['phaseName'] as String? ?? '',
    );
  }
}