// lib/models/UserSettings/program_definition_dto.dart
class ProgramDefinitionDto {
  final int programNo;
  final String modulName;
  final String programName;

  ProgramDefinitionDto({
    required this.programNo,
    required this.modulName,
    required this.programName,
  });

  factory ProgramDefinitionDto.fromJson(Map<String, dynamic> json) {
    return ProgramDefinitionDto(
      programNo: json['programNo'] as int? ?? 0,
      modulName: json['modulName'] as String? ?? '',
      programName: json['programName'] as String? ?? '',
    );
  }

  // Dropdown'da güzel görünmesi için bir helper
  String get display => '$modulName - $programName';
}