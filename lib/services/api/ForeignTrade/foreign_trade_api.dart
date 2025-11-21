// lib/services/api/foreign_trade_api.dart
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../../../models/result_model.dart';
import '../../../models/Helpers/base_card_view_model.dart';
import '../../../models/Helpers/paginated_search_query.dart';
import '../../../models/Helpers/paginated_result.dart';
import '../../../models/ForeignTrade/import_file_details_dto.dart';

class ForeignTradeApi {
  final Dio _dio = ApiClient().dio;

  // 1. İthalat Dosyalarını Ara (Paginated)
  Future<PaginatedResult<BaseCardViewModel>> searchImportFiles(PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/foreigntrade/search-import-files',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedResult.fromJson(resultModel.result!, (json) => BaseCardViewModel.fromJson(json));
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 2. İthalat Dosyası Detaylarını Getir (3 Liste)
  Future<ImportFileDetailsDto> getImportFileDetails(String importFileId) async {
    try {
      final response = await _dio.get('api/foreigntrade/import-file-details/$importFileId');
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return ImportFileDetailsDto.fromJson(resultModel.result!);
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}