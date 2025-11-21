import 'package:dio/dio.dart';
import '../../models/result_model.dart';
// Modeller
import '../../models/CreditLimit/create_credit_limit_request_dto.dart';
import '../../models/CreditLimit/credit_limit_request_details_dto.dart';
import '../../models/Helpers/paginated_search_query.dart';
import '../../models/Helpers/paginated_result.dart';
import '../../models/Helpers/base_card_view_model.dart';
// Motor
import 'core/api_client.dart';

class CreditLimitApi {
  final Dio _dio = ApiClient().dio;

  // 1. Kredi Limit Talebi Oluştur/Güncelle
  Future<bool> createCreditLimitRequest(CreateCreditLimitRequestDto dto) async {
    try {
      final response = await _dio.post(
        'api/creditlimit/create',
        data: dto.toJson(),
      );

      final resultModel = ResultModel<dynamic>.fromJson(response.data);
      
      // Sadece isSuccessful kontrolü (Sizin son isteğinize göre)
      if (resultModel.isSuccessful) {
        return true;
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 2. Mevcut Kredi Limit Taleplerini Ara (Sorduğunuz Metot)
  Future<PaginatedResult<BaseCardViewModel>> searchCreditLimitRequests(PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/search/creditlimitrequests',
        queryParameters: query.toQueryParameters(),
      );

      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedResult.fromJson(
          resultModel.result!, 
          (json) => BaseCardViewModel.fromJson(json)
        );
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 3. DocumentNumber ile Tek Bir Kredi Talebi Getir
  Future<CreditLimitRequestDetailsDto> getRequestByDocumentNumber(String documentNumber) async {
    try {
      final response = await _dio.get('api/creditlimit/by-doc-number/$documentNumber');
      
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return CreditLimitRequestDetailsDto.fromJson(resultModel.result!);
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}