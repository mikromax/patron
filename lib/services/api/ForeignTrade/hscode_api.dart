import 'package:dio/dio.dart';
import 'package:patron/models/Helpers/BaseModuleExport.dart';
import '../core/api_client.dart';
import '../../../models/result_model.dart';
import '../../../models/ForeignTrade/HsCode/hs_code_tree_node_dto.dart';
import '../../../models/ForeignTrade/HsCode/hs_code_detail_dto.dart';
import '../../../models/ForeignTrade/HsCode/hs_code_reference_price_dto.dart';
import '../../../models/ForeignTrade/HsCode/create_reference_price_dto.dart';
import '../../../models/ForeignTrade/HsCode/update_reference_price_dto.dart';
class HsCodeApi {
  final Dio _dio = ApiClient().dio;

  // Tüm HsCode ağaç listesini getirir
  Future<List<HsCodeTreeNodeDto>> getTreeList() async {
    try {
      final response = await _dio.get('api/hscodes/tree-list');

      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => HsCodeTreeNodeDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
Future<PaginatedResult<HsCodeDetailDto>> searchHsCodes(PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/hscodes/search',
        queryParameters: query.toQueryParameters(),
      );

      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        // Dönüş tipi PaginatedResult<HsCodeDetailDto> olacak
        return PaginatedResult.fromJson(
          resultModel.result!,
          (json) => HsCodeDetailDto.fromJson(json),
        );
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
  Future<List<HsCodeReferencePriceDto>> getHsCodeReferencePrices(String hsCodeId, {bool includeExpired = false}) async {
    try {
      final response = await _dio.get(
        'api/hscodes/$hsCodeId/reference-prices',
        queryParameters: {
          'includeExpired': includeExpired.toString(),
        },
      );

      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => HsCodeReferencePriceDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
  // YENİ METOT 1: Referans Fiyat Oluştur
  Future<bool> createReferencePrice(CreateReferencePriceDto dto) async {
    try {
      final response = await _dio.post(
        'api/hscodes/create-reference-price',
        data: dto.toJson(),
      );
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // YENİ METOT 2: Referans Fiyat Güncelle
  Future<bool> updateReferencePrice(String id, UpdateReferencePriceDto dto) async {
    try {
      final response = await _dio.put(
        'api/hscodes/update-reference-price/$id',
        data: dto.toJson(),
      );
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}