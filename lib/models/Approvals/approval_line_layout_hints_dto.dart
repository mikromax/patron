// lib/models/approval_line_layout_hints_dto.dart
import '../Helpers/field_hint_dto.dart';

class ApprovalLineLayoutHintsDto {
  final List<FieldHintDto> lineSummaryFields;
  final List<FieldHintDto> lineDetailFields;

  ApprovalLineLayoutHintsDto({
    required this.lineSummaryFields,
    required this.lineDetailFields,
  });

  factory ApprovalLineLayoutHintsDto.fromJson(Map<String, dynamic> json) {
    var summaryList = (json['lineSummaryFields'] as List<dynamic>?)
        ?.map((item) => FieldHintDto.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];
    
    var detailList = (json['lineDetailFields'] as List<dynamic>?)
        ?.map((item) => FieldHintDto.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    summaryList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    detailList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ApprovalLineLayoutHintsDto(
      lineSummaryFields: summaryList,
      lineDetailFields: detailList,
    );
  }
}