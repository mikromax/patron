// lib/models/patron_query_request_dto.dart
class PatronQueryRequestDto {
  final String userPrompt;

  PatronQueryRequestDto({required this.userPrompt});

  Map<String, dynamic> toJson() {
    return {
      'UserPrompt': userPrompt,
    };
  }
}