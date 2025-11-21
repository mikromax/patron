import 'package:dio/dio.dart';
import '../../models/result_model.dart';
import 'core/api_client.dart';

class AiApi {
  final Dio _dio = ApiClient().dio;

  Future<List<Map<String, dynamic>>> getAiQueryResult(String userPrompt) async {
    try {
      final response = await _dio.post(
        'api/AiFunctions/texttosql',
        data: {'UserPrompt': userPrompt},
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!.cast<Map<String, dynamic>>();
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}