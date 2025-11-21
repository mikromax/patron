// lib/models/approval_lines_response_dto.dart
import 'pending_approval_line_dto.dart';
import 'approval_line_layout_hints_dto.dart';

class ApprovalLinesResponseDto {
  final List<PendingApprovalLineDto> lines;
  final ApprovalLineLayoutHintsDto layoutHints;

  ApprovalLinesResponseDto({
    required this.lines,
    required this.layoutHints,
  });

  factory ApprovalLinesResponseDto.fromJson(Map<String, dynamic> json) {
    var linesList = (json['lines'] as List<dynamic>?)
        ?.map((item) => PendingApprovalLineDto.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    return ApprovalLinesResponseDto(
      lines: linesList,
      layoutHints: ApprovalLineLayoutHintsDto.fromJson(json['layoutHints'] as Map<String, dynamic>),
    );
  }
}