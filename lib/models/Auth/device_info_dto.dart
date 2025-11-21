// lib/models/device_info_dto.dart
class DeviceInfoDto {
  final String deviceName;
  final String appVersion;
  final String osVersion;

  DeviceInfoDto({
    required this.deviceName,
    required this.appVersion,
    required this.osVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'DeviceName': deviceName,
      'AppVersion': appVersion,
      'OsVersion': osVersion,
    };
  }
}