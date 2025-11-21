import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'config_service.dart';
import 'api/settings_api.dart';
import '../models/UserSettings/user_widget_dto.dart';
import '../models/UserSettings/user_with_claims.dart';
import '../models/Auth/device_info_dto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;
import 'api/session_api.dart';
import '../models/Auth/session_details_dto.dart';
import 'api/auth_api.dart';
import '../models/Helpers/base_card_view_model.dart';
import '../models/Auth/change_firm_dto.dart';
import '../models/Auth/new_session_dto.dart';
class AuthService {
  final _storage = const FlutterSecureStorage();
  final _configService = ConfigService();
   final AuthApi _authApi = AuthApi();
  final SessionApi _sessionApi = SessionApi();
  static const _tokenKey = 'auth_token';
  static const _sessionIdKey = 'session_id';
static const _permissionsKey = 'widget_permissions';
static const _contextKey = 'user_context'; 

 Future<String?> getIdentityServerUrl() async {
    final config = await _configService.getDefaultConfig();
    if (config == null) return null;

    // 1. YENİ ENDPOINT YOLU
    final urlString = config.url.endsWith('/')
        ? '${config.url}api/Configuration/getidentity'
        : '${config.url}/api/Configuration/getidentity';
    
    final response = await http.get(Uri.parse(urlString));

    if (response.statusCode == 200) {
      // 2. YENİ PARSE ETME MANTIĞI
      // Artık ResultModel beklemiyoruz, doğrudan ham JSON'ı parse ediyoruz.
      final jsonResponse = jsonDecode(response.body);
      
      // Gelen JSON'dan 'authority' alanını al
      final authorityUrl = jsonResponse['authority'] as String?;
      
      if (authorityUrl != null && authorityUrl.isNotEmpty) {
        return authorityUrl;
      } else {
        throw Exception("API yanıtında 'authority' alanı bulunamadı.");
      }
    } else {
      throw Exception('Identity sunucu bilgisi alınamadı: ${response.statusCode}');
    }
  }
  Future<void> saveSessionId(String sessionId) async {
    await _storage.write(key: _sessionIdKey, value: sessionId);
  }
    // Login'den sonra veya uygulama açılışında o anki bağlamı çeker ve saklar
  Future<SessionDetailsDto> fetchAndSaveCurrentContext() async {
    try {
      final contextDto = await _authApi.getMyCurrentContext();
      // DTO'yu JSON string'e çevirip sakla
      await _storage.write(key: _contextKey, value: jsonEncode(contextDto.toJson()));
      return contextDto;
    } catch (e) {
      throw Exception('Mevcut bağlam (context) bilgisi alınamadı: $e');
    }
  }
  // Cihaz hafızasından o anki bağlamı okur
  Future<SessionDetailsDto?> getCurrentContext() async {
    final contextJson = await _storage.read(key: _contextKey);
    if (contextJson == null) return null;
    return SessionDetailsDto.fromJson(jsonDecode(contextJson));
  }
// Dropdown için TÜM firmaları getirir (AuthApi'yi çağırır)
  Future<List<BaseCardViewModel>> getAllFirms() {
    return _authApi.getMyFirms();
  }
 // Dropdown için BİR firmaya ait tesisleri getirir (AuthApi'yi çağırır)
  Future<List<BaseCardViewModel>> getFacilitiesForFirm(String firmId) {
    return _authApi.getFacilitiesByFirm(firmId);
  }
// Seçili firmayı/tesisi API'ye bildirir, YENİ SESSION alır ve kaydeder
  Future<void> changeCurrentContext(String firmId, String facilityId) async {
    final dto = ChangeFirmDto(firmId: firmId, facilityId: facilityId);
    
    // 1. API'yi çağırıp yeni session'ı al
    final NewSessionDto newSession = await _authApi.changeCurrentFirm(dto);
    
    // 2. Yeni Session ID'yi eskisinin üzerine yaz
    await saveSessionId(newSession.newSessionId);
    
    // 3. Hafızadaki bağlam bilgisini de güncelle
    // (Yeni session'ı aldığımıza göre, o anki bağlamı tekrar çekmek en doğrusu)
    await fetchAndSaveCurrentContext();
  }



  //  Tüm kullanıcıları Identity Server'dan çeker
  Future<List<UserWithClaims>> getUsersList() async {
    final token = await getToken();
    final identityServerUrl = await getIdentityServerUrl();
    if (token == null || identityServerUrl == null) throw Exception('Giriş yapılmamış veya Identity Server adresi bulunamadı.');

    // Endpoint'i Identity Server URL'si ile birleştiriyoruz
    final baseUrl = identityServerUrl.endsWith('/')
        ? '${identityServerUrl}Account/GetUsersList'
        : '$identityServerUrl/Account/GetUsersList';
    
    final uri = Uri.parse(baseUrl);
    final headers = {'Authorization': 'Bearer $token'};
    
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // API'nin doğrudan bir liste döndürdüğünü varsayıyoruz
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse
          .map((item) => UserWithClaims.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Kullanıcı listesi alınamadı: ${response.statusCode}');
    }
  }
  Future<void> fetchAndSaveWidgetPermissions() async {
    // Bu, ApiService'in bir örneğini gerektirir. 
    // Bu, mimari olarak en temiz yol olmayabilir (servislerin birbirini çağırması)
    // ama en hızlı çözümdür.
    // Daha temizi, bu mantığı LoginScreen'e taşımaktır. Şimdilik burada kalsın.
    try {
      final apiService = SettingsApi(); 
      final permissions = await apiService.getUserWidgetPermissions();
      final permissionsJson = jsonEncode(permissions.map((p) => p.toJson()).toList());
      await _storage.write(key: _permissionsKey, value: permissionsJson);
    } catch (e) {
      // Yetkiler çekilemezse, eski yetkileri temizle
      await _storage.delete(key: _permissionsKey);
      throw Exception('Widget yetkileri çekilirken hata oluştu: $e');
    }
  }
  // YENİ METOT: Kayıtlı yetkileri hafızadan okur
  Future<List<UserWidgetDto>> getWidgetPermissions() async {
    final permissionsJson = await _storage.read(key: _permissionsKey);
    if (permissionsJson == null) {
      return [];
    }
    final List<dynamic> permissionsList = jsonDecode(permissionsJson);
    return permissionsList.map((json) => UserWidgetDto.fromJson(json)).toList();
  }
  // Identity Server'a bağlanıp token ister
  Future<bool> login(String identityServerUrl, String username, String password) async {
    // Identity Server'ın token verme adresi genellikle '/connect/token' olur.
    // Bu adres farklıysa, backend ekibinizden teyit edebilirsiniz.
    final tokenEndpoint = Uri.parse('$identityServerUrl/connect/token');
    
    final response = await http.post(
      tokenEndpoint,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      // Verdiğiniz yeni ve doğru bilgilere göre body'yi güncelliyoruz.
      body: {
        'grant_type': 'password',
        'client_id': 'V7.Api',
        'client_secret': 'CCFECED4-CCB5-46CE-B6C3-4648269ED138',
        'scope': 'Testing',
        'username': username, // Ekrandan gelen kullanıcı adı
        'password': password, // Ekrandan gelen parola
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['access_token'];
      if (token != null) {
        await saveToken(token);
        return true;
      }
    }
    // Hata durumunda daha anlamlı bir mesaj vermek için
    // sunucudan gelen hata mesajını da yakalayabiliriz.
    else {
      // Hata mesajını response body'sinden okumayı deneyelim
      final errorResponse = jsonDecode(response.body);
      final errorDescription = errorResponse['error_description'] ?? 'Token alınamadı.';
      throw Exception(errorDescription);
    }
    return false;
  }

  
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Token ve Session varsa giriş yapmış sayılır
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final session = await getSessionId();
    return token != null && session != null;
  }

  Future<String?> getSessionId() async {
    return await _storage.read(key: _sessionIdKey);
  }
 Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _sessionIdKey); // Session'ı da sil
  }
  Future<void> registerSession() async {
    // 1. Cihaz Bilgilerini Topla
    final deviceInfo = await _getDeviceInfo();

    // 2. API'yi çağır
    final sessionId = await _sessionApi.registerToken(deviceInfo);

    // 3. Dönen Session ID'yi kaydet
    await saveSessionId(sessionId);
  }
  Future<DeviceInfoDto> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    String deviceName = 'Unknown';
    String osVersion = 'Unknown';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceName = androidInfo.model;
      osVersion = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceName = iosInfo.name;
      osVersion = 'iOS ${iosInfo.systemVersion}';
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfoPlugin.windowsInfo;
      deviceName = windowsInfo.productName;
      osVersion = 'Windows ${windowsInfo.displayVersion}';
    }
    
    return DeviceInfoDto(
      deviceName: deviceName,
      appVersion: packageInfo.version,
      osVersion: osVersion,
    );
  }
}