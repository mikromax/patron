import 'package:dio/dio.dart';
import '../../models/Auth/device_info_dto.dart';
import 'core/api_client.dart';

class SessionApi {
  final Dio _dio = ApiClient().dio;

  // Session'ı kaydeder ve SessionId'yi döndürür
  Future<String> registerToken(DeviceInfoDto dto) async {
    try {
      final response = await _dio.post(
        'api/auth/register-token', // API yolunuz
        data: dto.toJson(),
      );

      if (response.data != null && response.data['sessionId'] != null) {
        return response.data['sessionId'] as String;
      } else {
        throw Exception('API yanıtında SessionId bulunamadı.');
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}