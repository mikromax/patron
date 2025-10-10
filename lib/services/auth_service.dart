import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'config_service.dart';
import '../models/result_model.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _configService = ConfigService();
  static const _tokenKey = 'auth_token';

  // Bu fonksiyon doğru ve değişmedi.
  Future<String?> getIdentityServerUrl() async {
    final config = await _configService.getDefaultConfig();
    if (config == null) return null;

    final urlString = config.url.endsWith('/') 
        ? '${config.url}IdentityInfo/Get' 
        : '${config.url}/IdentityInfo/Get';
    
    final response = await http.get(Uri.parse(urlString));
    if (response.statusCode == 200) {
      final resultModel = ResultModel<String>.fromJson(jsonDecode(response.body));
      if (resultModel.isSuccessful) return resultModel.result;
    }
    return null;
  }

  // --- DEĞİŞİKLİK BURADA ---
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
  // --- DEĞİŞİKLİK SONU ---

  // Bu fonksiyonlar doğru ve değişmedi.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
  
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}