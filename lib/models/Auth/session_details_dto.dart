class SessionDetailsDto {
  final String id;
  final String? currentFirmId;
  final String? currentFacilityId;
  final String? deviceName;
  final String? currentFirmCurrencyCode;

  SessionDetailsDto({
    required this.id,
    this.currentFirmId,
    this.currentFacilityId,
    this.deviceName,
    this.currentFirmCurrencyCode,
  });

  factory SessionDetailsDto.fromJson(Map<String, dynamic> json) {
    return SessionDetailsDto(
      id: json['id'] as String,
      currentFirmId: json['currentFirmId'] as String?,
      currentFacilityId: json['currentFacilityId'] as String?,
      deviceName: json['deviceName'] as String?,
      currentFirmCurrencyCode: json['currentFirmCurrencyCode'] as String?,
    );
  }

  // Cihaz hafızasına kaydetmek için
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentFirmId': currentFirmId,
      'currentFacilityId': currentFacilityId,
      'deviceName': deviceName,
      'currentFirmCurrencyCode':currentFirmCurrencyCode,
    };
  }
}