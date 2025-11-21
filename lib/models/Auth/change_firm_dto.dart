class ChangeFirmDto {
  final String firmId;
  final String facilityId;

  ChangeFirmDto({required this.firmId, required this.facilityId});

  Map<String, dynamic> toJson() {
    return {
      'FirmId': firmId,
      'FacilityId': facilityId,
    };
  }
}