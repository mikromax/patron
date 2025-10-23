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
import '../models/inventory_status_dto.dart';
import '../models/get_inventory_status_query.dart';
import '../models/bank_credits_vm.dart';
import '../models/get_bank_credits_query.dart';
import '../models/nonecash_assets_vm.dart';
import '../models/get_nonecash_assets_query.dart';
import '../models/orders_by_customer_vm.dart';
import '../models/base_card_view_model.dart';
import '../models/get_all_orders_by_customer_query.dart';
import '../models/cancel_with_quantity_command.dart';
import '../models/approve_with_quantity_command.dart';
import '../models/balance_aging_chart_vm.dart';
import '../models/get_account_balance_aging_chart_query.dart';
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
  Future<List<BalanceAgingChartVM>> getAccountBalanceAgingChart(GetAccountBalanceAgingChartQuery query) async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();
    if (token == null || config == null) throw Exception('Yapılandırma veya giriş hatası.');

    final baseUrl = config.url.endsWith('/')
        ? '${config.url}mikro/FinancialOperations/GetAccountBalanceAgingChart'
        : '${config.url}/mikro/FinancialOperations/GetAccountBalanceAgingChart';
    
    final uri = Uri.parse(baseUrl).replace(queryParameters: query.toQueryParameters());
    final headers = {'Authorization': 'Bearer $token'};
    
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => BalanceAgingChartVM.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception('API Sunucu Hatası: ${response.statusCode}');
    }
  }
Future<List<BaseCardViewModel>> getOrderCancelReasons() async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();
    if (token == null || config == null) throw Exception('Yapılandırma veya giriş hatası.');

    final baseUrl = config.url.endsWith('/')
        ? '${config.url}mikro/Order/GetOrderCancelResons' // Adres Resons -> Reasons olabilir, API'den teyit edin
        : '${config.url}/mikro/Order/GetOrderCancelResons';
    
    final uri = Uri.parse(baseUrl); // Parametre yok
    final headers = {'Authorization': 'Bearer $token'};
    
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => BaseCardViewModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception('API Sunucu Hatası: ${response.statusCode}');
    }
  }
Future<List<OrdersByCustomerVM>> searchOrdersByCustomer(GetAllOrdersByCustomerQuery query) async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();
    if (token == null || config == null) throw Exception('Yapılandırma veya giriş hatası.');

    final baseUrl = config.url.endsWith('/')
        ? '${config.url}mikro/Order/SearchOrdersByCustomer'
        : '${config.url}/mikro/Order/SearchOrdersByCustomer';
    
    final uri = Uri.parse(baseUrl).replace(queryParameters: query.toQueryParameters());
    final headers = {'Authorization': 'Bearer $token'};
    
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => OrdersByCustomerVM.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception('API Sunucu Hatası: ${response.statusCode}');
    }
  }
Future<bool> cancelOrderWithQuantity(CancelWithQuantityCommand command) async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();
    if (token == null || config == null) throw Exception('Yapılandırma veya giriş hatası.');

    final urlString = config.url.endsWith('/')
        ? '${config.url}mikro/SalesOrders/CancelWithQuantity'
        : '${config.url}/mikro/SalesOrders/CancelWithQuantity';
    
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    
    final body = jsonEncode(command.toJson());

    final response = await http.post(Uri.parse(urlString), headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel.fromJson(jsonResponse); // Unit döndüğü için <T> belirtmeye gerek yok
      if (resultModel.isSuccessful) {
        return true;
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } else {
      throw Exception('API Sunucu Hatası: ${response.statusCode}');
    }
  }
  Future<bool> approveOrderWithQuantity(ApproveWithQuantityCommand command) async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();
    if (token == null || config == null) throw Exception('Yapılandırma veya giriş hatası.');

    final urlString = config.url.endsWith('/')
        ? '${config.url}mikro/SalesOrders/ApproveWithQuantity'
        : '${config.url}/mikro/SalesOrders/ApproveWithQuantity';
    
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    
    final body = jsonEncode(command.toJson());

    final response = await http.post(Uri.parse(urlString), headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel.fromJson(jsonResponse);
      if (resultModel.isSuccessful) {
        return true;
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } else {
      throw Exception('API Sunucu Hatası: ${response.statusCode}');
    }
  }
Future<List<NonecashAssetsVM>> getNoneCashAssets(GetNoneCashAssetsQuery query) async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();
    if (token == null) throw Exception('Giriş yapılmamış (Token bulunamadı).');
    if (config == null) throw Exception('API yapılandırması bulunamadı.');

    final baseUrl = config.url.endsWith('/')
        ? '${config.url}mikro/MikroCashAsstesInfo/GetNoneCashAssets'
        : '${config.url}/mikro/MikroCashAsstesInfo/GetNoneCashAssets';
    
    final uri = Uri.parse(baseUrl).replace(queryParameters: query.toQueryParameters());
    final headers = {'Authorization': 'Bearer $token'};
    
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => NonecashAssetsVM.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception('API Sunucu Hatası: ${response.statusCode}');
    }
  }
Future<List<BankCreditsVM>> getBankCredits(GetBankCreditsQuery query) async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();
    if (token == null) throw Exception('Giriş yapılmamış (Token bulunamadı).');
    if (config == null) throw Exception('API yapılandırması bulunamadı.');

    final baseUrl = config.url.endsWith('/')
        ? '${config.url}mikro/MikroCashAsstesInfo/GetBankCredits'
        : '${config.url}/mikro/MikroCashAsstesInfo/GetBankCredits';
    
    final uri = Uri.parse(baseUrl).replace(queryParameters: query.toQueryParameters());
    final headers = {'Authorization': 'Bearer $token'};
    
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => BankCreditsVM.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception('API Sunucu Hatası: ${response.statusCode}');
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

    // 1. Temel URL'yi oluştur.
    final baseUrl = config.url.endsWith('/')
        ? '${config.url}ai/AiFunctions/GetAiQueryResult'
        : '${config.url}/ai/AiFunctions/GetAiQueryResult';
    
    // 2. Dart'ın Uri sınıfını kullanarak URL'yi parametrelerle güvenli bir şekilde oluştur.
    //    C# tarafındaki parametre adının 'prompt' olduğunu varsayıyoruz.
    final uri = Uri.parse(baseUrl).replace(
     queryParameters: {
        // ÖNEMLİ: 'Prompt' kelimesi, C#'taki GenerateSqlFromPromptQuery
        // sınıfının içindeki özelliğin adıyla BİREBİR AYNI olmalıdır.
        // Eğer C#'taki ad farklıysa, burayı da ona göre değiştirin.
        'UserPrompt': userPrompt,
     },
    );

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    // 3. POST yerine GET kullan. Body göndermiyoruz.
    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!.cast<Map<String, dynamic>>();
      } else {
        throw Exception(resultModel.errors.isNotEmpty ? resultModel.errors.join('\n') : "API'deki AI servisinden başarısız yanıt döndü.");
      }
    } else {
      throw Exception('AI Gateway API Hatası: ${response.statusCode}');
    }
  }
  Future<List<InventoryStatusDto>> getInventoryStatus(GetInventoryStatusQuery query) async {
    final token = await _authService.getToken();
    final config = await _configService.getDefaultConfig();
    if (token == null) throw Exception('Giriş yapılmamış (Token bulunamadı).');
    if (config == null) throw Exception('API yapılandırması bulunamadı.');

    // --- DEĞİŞİKLİK: Yeni API Yolu ---
    final baseUrl = config.url.endsWith('/')
        ? '${config.url}mikro/MikroCashAsstesInfo/GetItemInventoryDetails'
        : '${config.url}/mikro/MikroCashAsstesInfo/GetItemInventoryDetails';
    
    // Parametre olmadığı için queryParameters boş olacak, bu doğru.
    final uri = Uri.parse(baseUrl).replace(queryParameters: query.toQueryParameters());
    final headers = {'Authorization': 'Bearer $token'};
    
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final resultModel = ResultModel<List<dynamic>>.fromJson(jsonResponse);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => InventoryStatusDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception('API Sunucu Hatası: ${response.statusCode}');
    }
  }
}

// ...