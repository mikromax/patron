import 'package:dio/dio.dart';
import 'core/api_client.dart';
// Modeller
import '../../models/result_model.dart';
import '../../models/BusinessPartners/business_partner_dto.dart';
import '../../models/Helpers/paginated_search_query.dart';
import '../../models/Helpers/paginated_result.dart';

class BusinessPartnerApi {
  final Dio _dio = ApiClient().dio;

  // BP Listeleme (Arama)
  Future<PaginatedResult<BusinessPartnerDto>> search(PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/BusinessPartners/search',
        queryParameters: query.toQueryParameters(),
      );

      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedResult.fromJson(
          resultModel.result!, 
          (json) => BusinessPartnerDto.fromJson(json)
        );
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}