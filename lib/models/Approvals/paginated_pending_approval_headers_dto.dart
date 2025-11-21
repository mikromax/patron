// lib/models/paginated_pending_approval_headers_dto.dart
import 'approval_layout_hints_dto.dart';
import 'pending_approval_header_dto.dart';
import '../Helpers/paginated_result.dart'; // Mevcut paginated result modelimizi kullanıyoruz

class PaginatedPendingApprovalHeadersDto {
  final PaginatedResult<PendingApprovalHeaderDto> paginatedData;
  final ApprovalLayoutHintsDto layoutHints;

  PaginatedPendingApprovalHeadersDto({
    required this.paginatedData,
    required this.layoutHints,
  });

  factory PaginatedPendingApprovalHeadersDto.fromJson(Map<String, dynamic> json) {
    return PaginatedPendingApprovalHeadersDto(
      paginatedData: PaginatedResult.fromJson(
        json['paginatedData'] as Map<String, dynamic>,
        (itemJson) => PendingApprovalHeaderDto.fromJson(itemJson),
      ),
      layoutHints: ApprovalLayoutHintsDto.fromJson(json['layoutHints'] as Map<String, dynamic>),
    );
  }
}