import 'package:dio/dio.dart';
import '../../models/result_model.dart';
// Modeller
import '../../models/Approvals/approval_document_type.dart';
import '../../models/Approvals/approve_document_dto.dart';
import '../../models/Approvals/cancel_document_dto.dart';
import '../../models/Approvals/paginated_pending_approval_headers_dto.dart';
import '../../models/Approvals/approval_lines_response_dto.dart';
import '../../models/Helpers/paginated_search_query.dart';
// Motor
import 'core/api_client.dart';

class ApprovalsApi {
  // Motorumuzu çağırıyoruz (Token ve URL işlerini bu hallediyor)
  final Dio _dio = ApiClient().dio;

  // 1. Onay Bekleyenleri Listele
  Future<PaginatedPendingApprovalHeadersDto> getPendingApprovals(
    ApprovalDocumentType documentType, 
    PaginatedSearchQuery pagination
  ) async {
    try {
      // Parametreleri hazırlıyoruz
      final queryParams = pagination.toQueryParameters();
      queryParams['documentType'] = documentType.value.toString();

      // İstek (Sadece endpoint yolu yeterli)
      final response = await _dio.get(
        'api/approvals/pending', 
        queryParameters: queryParams,
      );

      // Dio, JSON'ı otomatik decode eder (response.data bir Map'tir)
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedPendingApprovalHeadersDto.fromJson(resultModel.result!);
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      // Interceptor hatayı zaten düzenledi, direkt fırlatıyoruz
      throw Exception(e.error);
    }
  }

  // 2. Evrak Onayla
  Future<bool> approveDocument(ApproveDocumentDto dto) async {
    try {
      final response = await _dio.post(
        'api/approvals/approve',
        data: dto.toJson(), // Body olarak gönderiyoruz
      );

      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 3. Evrak İptal Et (Kapat)
  Future<bool> cancelDocument(CancelDocumentDto dto) async {
    try {
      final response = await _dio.post(
        'api/approvals/cancel',
        data: dto.toJson(),
      );

      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 4. Evrak Satırlarını Getir
  Future<ApprovalLinesResponseDto> getApprovalLines(
    ApprovalDocumentType documentType, 
    String documentNumber
  ) async {
    try {
      final response = await _dio.get(
        'api/approvals/lines',
        queryParameters: {
          'documentNumber': documentNumber,
          'documentType': documentType.value.toString(),
        },
      );

      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return ApprovalLinesResponseDto.fromJson(resultModel.result!);
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}