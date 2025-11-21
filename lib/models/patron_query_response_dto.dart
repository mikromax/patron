// lib/models/patron_query_response_dto.dart
class PatronQueryResponseDto {
  final String queryLogId;
  final List<Map<String, dynamic>> data;

  PatronQueryResponseDto({required this.queryLogId, required this.data});

  factory PatronQueryResponseDto.fromJson(Map<String, dynamic> json) {
    // Gelen 'data' listesini doğru tipe dönüştürüyoruz
    var dataList = (json['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return PatronQueryResponseDto(
      queryLogId: json['queryLogId'] as String,
      data: dataList,
    );
  }
}