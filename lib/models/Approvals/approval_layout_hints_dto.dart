// lib/models/approval_layout_hints_dto.dart
import '../Helpers/field_hint_dto.dart';

class ApprovalLayoutHintsDto {
  final List<FieldHintDto> headerSummaryFields;
  final List<FieldHintDto> headerDetailFields;

  ApprovalLayoutHintsDto({
    required this.headerSummaryFields,
    required this.headerDetailFields,
  });

  factory ApprovalLayoutHintsDto.fromJson(Map<String, dynamic> json) {
    var summaryList = (json['headerSummaryFields'] as List<dynamic>?)
        ?.map((item) => FieldHintDto.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];
    
    var detailList = (json['headerDetailFields'] as List<dynamic>?)
        ?.map((item) => FieldHintDto.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    // Gelen listeyi SortOrder'a göre sıralayalım ki UI'da düzgün görünsün
    summaryList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    detailList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ApprovalLayoutHintsDto(
      headerSummaryFields: summaryList,
      headerDetailFields: detailList,
    );
  }
}