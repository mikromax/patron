import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'config_service.dart';
import '../models/result_model.dart';
import '../models/nakit_varliklar_model.dart';
import '../models/account_transaction_statement_dto.dart';
import '../models/statement_detail_model.dart';
import '../models/account_credit_debit_status_dto.dart';
import '../models/get_account_credit_debit_status_query.dart';
class ApiService {
  final _configService = ConfigService();
  final _authService = AuthService();

  Future<NakitVarliklar> getCashAssets() async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();

    if (token == null) throw Exception('Giriş yapılmamış (Token bulunamadı).');
    if (config == null) throw Exception('API yapılandırması bulunamadı.');

    final urlString = config.url.endsWith('/')
        ? '${config.url}mikro/MikroCashAsstesInfo/GetCashAssets'
        : '${config.url}/mikro/MikroCashAsstesInfo/GetCashAssets';
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(urlString), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        
        List<Detail> detailsList = resultModel.result!
            .map((item) => Detail.fromJson(item as Map<String, dynamic>))
            .toList();

        return NakitVarliklar(details: detailsList);

      } else {
        throw Exception(resultModel.errors.isNotEmpty ? resultModel.errors.join('\n') : "API'den boş veya başarısız veri döndü.");
      }
    } else {
      // API'den 200 dışında bir kod dönerse, yanıtın içeriğini de hataya ekleyelim.
      // Bu, 401 gibi durumlarda daha fazla bilgi verebilir.
      final responseBody = response.body;
      throw Exception('API Sunucu Hatası: ${response.statusCode}\nYanıt: $responseBody');
    }
  }
   Future<List<StatementDetailModel>>  getAccountStatement(AccountTransactionStatementDto dto) async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();

    if (token == null) throw Exception('Giriş yapılmamış (Token bulunamadı).');
    if (config == null) throw Exception('API yapılandırması bulunamadı.');

    // 1. Temel URL'yi oluştur.
    final baseUrl = config.url.endsWith('/')
        ? '${config.url}mikro/MikroCashAsstesInfo/GetAccountTransactionStatement'
        : '${config.url}/mikro/MikroCashAsstesInfo/GetAccountTransactionStatement';
    
    // 2. Dart'ın Uri sınıfını kullanarak URL'yi parametrelerle güvenli bir şekilde oluştur.
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: dto.toQueryParameters(), // DTO'dan gelen parametreleri ekle
    );

    final headers = {'Authorization': 'Bearer $token'};

    // 3. POST yerine GET kullan. Body göndermiyoruz.
    //final response = await http.get(uri, headers: headers);
    final response = await http.get(uri, headers: headers).timeout(
      const Duration(seconds: 300), // Örneğin 60 saniye sonra zaman aşımına uğrat
      onTimeout: () {
        // Zaman aşımı durumunda özel bir hata mesajı döndür
        throw Exception('Sunucuya bağlanırken zaman aşımına uğradı. Lütfen tekrar deneyin.');
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
              .map((item) => StatementDetailModel.fromJson(item as Map<String, dynamic>))
              .toList();
      } else {
        throw Exception(resultModel.errors.isNotEmpty ? resultModel.errors.join('\n') : "API'den boş veya başarısız veri döndü.");
      }
    } else {
      final responseBody = response.body;
      throw Exception('API Sunucu Hatası: ${response.statusCode}\nYanıt: $responseBody');
    }
  }
Future<List<AccountCreditDebitStatusDto>> getAccountCreditDebitStatus(GetAccountCreditDebitStatusQuery query) async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();
    if (token == null) throw Exception('Giriş yapılmamış (Token bulunamadı).');
    if (config == null) throw Exception('API yapılandırması bulunamadı.');

    final baseUrl = config.url.endsWith('/')
        ? '${config.url}mikro/MikroCashAsstesInfo/GetAccountCreditDebit'
        : '${config.url}/mikro/MikroCashAsstesInfo/GetAccountCreditDebit';
    
    final uri = Uri.parse(baseUrl).replace(queryParameters: query.toQueryParameters());
    final headers = {'Authorization': 'Bearer $token'};
    
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => AccountCreditDebitStatusDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return []; // Boş veya başarısız ise boş liste döndür
    } else {
      throw Exception('API Sunucu Hatası: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getAiQueryResult(String userPrompt) async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();

    if (token == null) throw Exception('Giriş yapılmamış (Token bulunamadı).');
    if (config == null) throw Exception('API yapılandırması bulunamadı.');

    final urlString = config.url.endsWith('/')
        ? '${config.url}ai/AiFunctions/GetAiQueryResult'
        : '${config.url}/ai/AiFunctions/GetAiQueryResult';
    
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    // API'ye sadece kullanıcı sorusunu içeren bir JSON gönderiyoruz
    final body = jsonEncode({
      'prompt': userPrompt,
    });

    final response = await http.post(
      Uri.parse(urlString),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      // Dönen verinin ResultModel<List<dynamic>> olduğunu varsayıyoruz.
      // Her bir eleman bir Map<String, dynamic> (yani bir satır) olacak.
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        // Gelen listeyi List<Map<String, dynamic>> tipine dönüştürüyoruz
        return resultModel.result!.cast<Map<String, dynamic>>();
      } else {
        throw Exception(resultModel.errors.isNotEmpty ? resultModel.errors.join('\n') : "API'deki AI servisinden başarısız yanıt döndü.");
      }
    } else {
      throw Exception('AI Gateway API Hatası: ${response.statusCode}');
    }
  }
}
// ...