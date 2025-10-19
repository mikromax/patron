import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'config_service.dart';
import '../models/result_model.dart';

class GeminiService {
  // Artık Google AI paketlerine veya .env'e ihtiyacımız yok.
  // Kendi servislerimizi kullanarak API'mizle konuşacağız.
  final _configService = ConfigService();
  final _authService = AuthService();

  // Bu metot, kullanıcı prompt'unu alıp kendi API'mize gönderir
  // ve API'nin Gemini'den aldığı JSON sorgusunu geri döndürür.
  Future<Map<String, dynamic>> generateQuery(String userPrompt) async {
    try {
      // 1. Gerekli bilgileri al: Token ve Root API Adresi
      final token = await _authService.getToken();
      final config = await _configService.getDefaultConfig();

      if (token == null) throw Exception('Giriş yapılmamış (Token bulunamadı).');
      if (config == null) throw Exception('API yapılandırması bulunamadı.');

      // 2. Backend'deki yeni AI endpoint'inin tam yolunu oluştur.
      //    Bu endpoint'i sizin oluşturmanız gerekecek.
      final urlString = config.url.endsWith('/')
          ? '${config.url}mikro/AIAssistant/GenerateQuery'
          : '${config.url}/mikro/AIAssistant/GenerateQuery';
      
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };

      // 3. API'ye göndereceğimiz body'yi oluştur.
      final body = jsonEncode({
        'userPrompt': userPrompt,
      });

      // 4. Kendi API'mize POST isteği yap.
      final response = await http.post(
        Uri.parse(urlString),
        headers: headers,
        body: body,
      );

      // 5. Yanıtı işle.
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Backend'in yine standart ResultModel<T> döndürdüğünü varsayıyoruz.
        // Bu sefer T, bir Map<String, dynamic> (yani bizim JSON sorgumuz).
        final resultModel = ResultModel<Map<String, dynamic>>.fromJson(jsonResponse);

        if (resultModel.isSuccessful && resultModel.result != null) {
          return resultModel.result!;
        } else {
          throw Exception(resultModel.errors.isNotEmpty ? resultModel.errors.join('\n') : "API'deki AI servisinden başarısız yanıt döndü.");
        }
      } else {
        throw Exception('AI Gateway API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI sorgusu oluşturulurken hata oluştu: $e');
    }
  }
}