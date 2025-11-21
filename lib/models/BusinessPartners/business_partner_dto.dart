class BusinessPartnerDto {
  final String id;
  final String code;
  final String title;
  final bool isActive;
  final String? regionId;
  final String? groupId;
  final String? sectorId;

  BusinessPartnerDto({
    required this.id,
    required this.code,
    required this.title,
    required this.isActive,
    this.regionId,
    this.groupId,
    this.sectorId,
  });

  factory BusinessPartnerDto.fromJson(Map<String, dynamic> json) {
    return BusinessPartnerDto(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      regionId: json['regionId'] as String?,
      groupId: json['groupId'] as String?,
      sectorId: json['sectorId'] as String?,
    );
  }
}