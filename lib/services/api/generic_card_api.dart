import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // debugPrint için
import 'core/api_client.dart';
import '../../models/result_model.dart';
import '../../models/Helpers/base_card_view_model.dart';
import '../../models/helpers/paginated_search_query.dart';
import '../../models/helpers/paginated_result.dart';

class GenericCardApi {
  final Dio _dio = ApiClient().dio;
  late final String controllerPath; // Örn: "api/Regions"

  // Constructor'da URL'nin sonundaki '/' işaretini temizliyoruz
  GenericCardApi(String endpoint) {
    controllerPath = endpoint.endsWith('/') 
        ? endpoint.substring(0, endpoint.length - 1) 
        : endpoint;
  }

  // 1. Listeleme (Search) -> api/Regions/Search
  Future<PaginatedResult<BaseCardViewModel>> search(PaginatedSearchQuery query) async {
    try {
      final url = '$controllerPath/Search';
      final response = await _dio.get(
        url,
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

  // 2. Ekleme (Create) -> api/Regions/Create
  Future<bool> create(BaseCardViewModel dto) async {
    try {
      final url = '$controllerPath/Create';
      final response = await _dio.post(
        url,
        data: dto.toJson(),
      );
      final resultModel = ResultModel.fromJson(response.data);
      
      if (!resultModel.isSuccessful) {
        throw Exception(resultModel.errors.join('\n'));
      }
      return true;
    } on DioException catch (e) {
      _handleError(e); // Özel hata yönetimi
      return false;
    }
  }

  // 3. Güncelleme (Update) -> api/Regions/Update/{id}
  Future<bool> update(BaseCardViewModel dto) async {
    try {
      // --- DÜZELTME BURADA: Action adı (Update) URL'e eklendi ---
      final url = '$controllerPath/Update';
      
      // Debug için konsola yazalım
      debugPrint('UPDATE İSTEĞİ GİDİYOR: $url');
      debugPrint('DATA: ${dto.toJson()}');

      final response = await _dio.post(
        url,
        data: dto.toJson(),
      );
      
      final resultModel = ResultModel.fromJson(response.data);
      
      if (!resultModel.isSuccessful) {
        throw Exception(resultModel.errors.join('\n'));
      }
      return true;
    } on DioException catch (e) {
      _handleError(e); // Özel hata yönetimi
      return false;
    }
  }

  // 4. Silme (Delete) -> api/Regions/Delete/{id}
  Future<bool> delete(String id) async {
    try {
      final url = '$controllerPath/Delete/$id';
      final response = await _dio.delete(url); 
      final resultModel = ResultModel.fromJson(response.data);
      
      if (!resultModel.isSuccessful) {
        throw Exception(resultModel.errors.join('\n'));
      }
      return true;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }

  // Hata Detaylarını Gösterme Yardımcısı
  void _handleError(DioException e) {
    if (e.response != null && e.response!.statusCode == 400) {
      // Sunucudan dönen doğrulama hatasını (Validation Error) yakala
      debugPrint("SUNUCU HATASI (400): ${e.response!.data}");
      throw Exception("Veri Hatası: ${e.response!.data}"); 
    }
    throw Exception(e.error);
  }
}