import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart'; // GlobalKey için
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config_service.dart';
// AuthService'e logout için ihtiyacımız var

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  final _storage = const FlutterSecureStorage();
  final _configService = ConfigService();
  
  // Navigasyon için global key
  static GlobalKey<NavigatorState>? _navigatorKey;

  // main.dart'tan çağırmak için
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  ApiClient._internal() {
    _dio = Dio();

    // SSL Hatasını Aşma
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // --- INTERCEPTOR (TÜM MANTIK BURADA) ---
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // A. Base URL'i ayarla
          final config = await _configService.getDefaultConfig();
          if (config == null) {
            return handler.reject(DioException(requestOptions: options, error: 'API Yapılandırması bulunamadı.'));
          }
          String baseUrl = config.url;
          if (!baseUrl.endsWith('/')) baseUrl += '/';
          options.baseUrl = baseUrl;

          // B. Token'ı al ve Header'a ekle
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // --- YENİ EKLENEN BÖLÜM: X-Session-Id ---
          final sessionId = await _storage.read(key: 'session_id');
          if (sessionId != null) {
            options.headers['X-Session-Id'] = sessionId;
          }
          // ----------------------------------------

          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // --- GÜNCELLENEN HATA YÖNETİMİ (401) ---
          if (e.response?.statusCode == 401) {
            // 401 Hatası (Yetkisiz)
            // Hem token hem de session geçersiz demektir.
            
            // 1. Arka planda her şeyi temizle
            // AuthService'i burada çağırmak circular dependency yaratabilir,
            // o yüzden doğrudan storage'ı temizleyelim.
            _storage.delete(key: 'auth_token');
            _storage.delete(key: 'session_id');

            // 2. Kullanıcıyı Login ekranına at
            if (_navigatorKey?.currentState != null) {
              _navigatorKey!.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
            }
            
            // 3. Kullanıcıya net bir hata fırlat
            return handler.reject(DioException(
              requestOptions: e.requestOptions,
              error: 'Oturum süreniz doldu veya yetkiniz yok. Lütfen tekrar giriş yapın.',
            ));
          }
          // --- 401 GÜNCELLEMESİ SONU ---

          // Diğer hatalar için (404, 500, internet yok vb.)
          String errorMessage = "Bir hata oluştu.";
          if (e.response != null) {
            errorMessage = "Hata: ${e.response!.statusCode} - ${e.response!.statusMessage}";
          } else {
            errorMessage = "Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.";
          }
          return handler.next(DioException(
            requestOptions: e.requestOptions,
            error: errorMessage,
          ));
        },
      ),
    );
  }

  Dio get dio => _dio;
}