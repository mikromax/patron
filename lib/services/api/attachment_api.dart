import 'dart:io';
import 'dart:typed_data'; // Uint8List için
import 'package:dio/dio.dart';
import '../../models/result_model.dart';
import '../../models/Attachments/attachment_summary_dto.dart';
import 'core/api_client.dart';

class AttachmentApi {
  final Dio _dio = ApiClient().dio;

  // 1. Dosya Yükleme
  Future<bool> uploadAttachment({
    required String entityId,
    required String entityName,
    required String documentTypeId,
    required File file,
  }) async {
    try {
      String fileName = file.path.split('/').last; // Veya Platform.separator kullanabilirsiniz
      
      // Dio için FormData oluşturuyoruz
      FormData formData = FormData.fromMap({
        'metadata.entityId': entityId,
        'metadata.entityName': entityName,
        'metadata.documentTypeId': documentTypeId,
        // Dosyayı MultipartFile olarak ekliyoruz
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        'api/attachments/upload',
        data: formData,
        // Dosya yüklemelerinde timeout süresini artırmak iyi olabilir
        options: Options(sendTimeout: const Duration(minutes: 2)),
      );

      // Genellikle 200 OK dönerse işlem başarılıdır
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 2. Dosyaları Listeleme
  Future<List<AttachmentSummaryDto>> getAttachmentsList(String entityName, String entityId, String documentTypeId) async {
    try {
      final response = await _dio.get(
        'api/attachments/list',
        queryParameters: {
          'entityName': entityName,
          'entityId': entityId,
          'documentTypeId': documentTypeId,
        },
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => AttachmentSummaryDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 3. Dosya Silme
  Future<bool> deleteAttachment(String attachmentId) async {
    try {
      final response = await _dio.delete('api/attachments/$attachmentId');
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 4. Dosya İndirme
  Future<({Uint8List bytes, String fileName})> downloadAttachment(String attachmentId, String defaultName) async {
    try {
      final response = await _dio.get(
        'api/attachments/download/$attachmentId',
        // Dosya içeriğini 'bytes' olarak istiyoruz
        options: Options(responseType: ResponseType.bytes),
      );

      String fileName = defaultName;
      // Header'dan dosya adını çekmeye çalışalım
      String? contentDisposition = response.headers.value('content-disposition');
      if (contentDisposition != null) {
        final nameMatch = RegExp(r'filename="?([^"]+)"?').firstMatch(contentDisposition);
        if (nameMatch != null && nameMatch.group(1) != null) {
          fileName = nameMatch.group(1)!;
        }
      }

      return (bytes: response.data as Uint8List, fileName: fileName);
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}