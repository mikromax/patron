import 'package:dio/dio.dart';
import 'dart:convert'; // jsonDecode için
import 'package:http/http.dart' as http; // Sadece getIdentityServerUrl için http kullanmaya devam ediyoruz (Token yokken)
import '../../models/UserSettings/user_with_claims.dart';
import '../config_service.dart';
import 'core/api_client.dart';
import '../../models/UserSettings/user_group_dto.dart';
import '../../models/UserSettings/register_view_model.dart';
import '../../models/Auth/change_firm_dto.dart';
import '../../models/Auth/new_session_dto.dart';
import '../../models/Auth/session_details_dto.dart';
import '../../models/Helpers/base_card_view_model.dart';
import '../../models/result_model.dart';
class AuthApi {
  final Dio _dio = ApiClient().dio;
  final _configService = ConfigService();

  // Bu metot henüz token olmadığı için ve özel bir işlem olduğu için 
  // ApiClient yerine manuel http kullanmaya devam edebilir veya
  // ApiClient'a "token ekleme" diyebileceğimiz bir özellik ekleyebiliriz.
  // Şimdilik güvenli yol olan manuel http ile devam edelim.
  // 1. O Anki Bağlamı Getir
  Future<SessionDetailsDto> getMyCurrentContext() async {
    try {
      // Bu istek Identity Server'a DEĞİL, ana API'mize gidiyor.
      // ApiClient (Dio) bunu otomatik olarak halledecek.
      final response = await _dio.get('api/auth/my-context');
      
      // Dönen ResultModel<SessionDetailsDto>
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return SessionDetailsDto.fromJson(resultModel.result!);
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 2. Erişilebilir Firmaları Listele
  Future<List<BaseCardViewModel>> getMyFirms() async {
    try {
      final response = await _dio.get('api/auth/my-firms');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => BaseCardViewModel.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 3. Firmaya Ait Tesisleri Listele
  Future<List<BaseCardViewModel>> getFacilitiesByFirm(String firmId) async {
    try {
      final response = await _dio.get('api/auth/facilities-by-firm/$firmId');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => BaseCardViewModel.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 4. Bağlamı Değiştir (Yeni Session ID Al)
  Future<NewSessionDto> changeCurrentFirm(ChangeFirmDto dto) async {
    try {
      final response = await _dio.post(
        'api/auth/change-firm',
        data: dto.toJson(),
      );
      
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return NewSessionDto.fromJson(resultModel.result!);
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
  Future<bool> createUser(RegisterViewModel model) async {
    try {
      final identityUrl = await getIdentityServerUrl();
      if (identityUrl == null) throw Exception('Identity Server adresi bulunamadı.');

      final fullUrl = identityUrl.endsWith('/')
          ? '${identityUrl}Account/CreateUserAsync'
          : '$identityUrl/Account/CreateUserAsync';

      final response = await _dio.post(
        fullUrl,
        data: model.toJson(),
      );

      // API başarılı ise 200 döner ve içeriğinde 'IsSuccessful' olabilir
      // Ancak C# kodunuza göre bazen direkt object dönüyor.
      // Genellikle 200 OK ise işlem başarılıdır.
      if (response.statusCode == 200) {
        final data = response.data;
        // Eğer API özel bir hata formatı dönüyorsa (IsSuccessful: false gibi) kontrol et
        if (data is Map && data.containsKey('isSuccessful') && data['isSuccessful'] == false) {
           // Hataları parse et
           final errors = data['errors'] as List<dynamic>? ?? [];
           final errorMsg = errors.map((e) => e['errorMessage'] ?? 'Hata').join('\n');
           throw Exception(errorMsg);
        }
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
  Future<List<UserGroupDto>> searchUserGroups() async {
    try {
      // Önce Identity URL'sini bul
      final identityUrl = await getIdentityServerUrl();
      if (identityUrl == null) throw Exception('Identity Server adresi bulunamadı.');

      // Endpoint yolunu oluştur
      final fullUrl = identityUrl.endsWith('/')
          ? '${identityUrl}UserGroup/Search'
          : '$identityUrl/UserGroup/Search';

      // Dio ile isteği at (ApiClient sayesinde Token otomatik eklenir)
      final response = await _dio.get(
        fullUrl,
        queryParameters: {'includePassive': false},
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => UserGroupDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
  Future<String?> getIdentityServerUrl() async {
    final config = await _configService.getDefaultConfig();
    if (config == null) return null;

    final urlString = config.url.endsWith('/')
        ? '${config.url}api/Configuration/getidentity'
        : '${config.url}/api/Configuration/getidentity';
    
    try {
      final response = await http.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final authorityUrl = jsonResponse['authority'] as String?;
        if (authorityUrl != null && authorityUrl.isNotEmpty) {
          return authorityUrl;
        } else {
          throw Exception("API yanıtında 'authority' alanı bulunamadı.");
        }
      } else {
        throw Exception('Identity sunucu bilgisi alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Sunucuya bağlanılamadı: $e');
    }
  }

  Future<bool> login(String identityServerUrl, String username, String password) async {
    final tokenEndpoint = '$identityServerUrl/connect/token';
    
    try {
      // Login işlemi de standart dışı (form-urlencoded) olduğu için Dio'nun
      // özel ayarlarıyla veya yine http ile yapılabilir. 
      // Basitlik için http ile devam ediyoruz.
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'client_id': 'V7.Api',
          'client_secret': 'CCFECED4-CCB5-46CE-B6C3-4648269ED138',
          'scope': 'Testing',
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['access_token'];
        if (token != null) {
          // Token'ı kaydetme işi AuthService'in (Business Logic) görevidir,
          // API sadece veriyi döner. Ancak mevcut yapıyı bozmamak için
          // burada token string'ini dönüp AuthService'de kaydedebiliriz.
          // Şimdilik eski mantığı koruyalım:
          return true; // Not: Token kaydetme işini AuthService yapacak
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorDescription = errorResponse['error_description'] ?? 'Token alınamadı.';
        throw Exception(errorDescription);
      }
      return false;
    } catch (e) {
      throw Exception('Giriş yapılamadı: $e');
    }
  }

  Future<List<UserWithClaims>> getUsersList(String identityServerUrl) async {
    // Bu istek Token gerektirir, o yüzden Dio (ApiClient) kullanabiliriz.
    // Ancak URL Identity Server olduğu için BaseUrl farklı.
    // Dio'ya tam URL (absolute URL) verirsek BaseURL'i ezer.
    try {
      final baseUrl = identityServerUrl.endsWith('/')
          ? '${identityServerUrl}Account/GetUsersList'
          : '$identityServerUrl/Account/GetUsersList';

      final response = await _dio.get(baseUrl);

      // API doğrudan liste dönüyor
      return (response.data as List)
          .map((item) => UserWithClaims.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}