import 'package:intl/intl.dart';

class AccountTransactionStatementDto {
  final String code;
  final DateTime startDate;
  final DateTime endDate;
  final int group;

  AccountTransactionStatementDto({
    required this.code,
    required this.startDate,
    required this.endDate,
    required this.group,
  });

  // Bu metot POST için kullanılıyordu, şimdilik kalabilir.
  Map<String, dynamic> toJson() {
    final DateFormat apiFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    return {
      'code': code,
      'startDate': apiFormatter.format(startDate),
      'endDate': apiFormatter.format(endDate),
      'group': group,
    };
  }
  
  // YENİ METOT: Nesnemizi GET isteği için bir query string map'ine çevirir.
  Map<String, String> toQueryParameters() {
    // API'nin beklediği tarih formatı (örn: "2025-10-13")
    // C# tarafı [FromQuery] ile DateTime'ı direkt parse edebilir.
    // Standart ISO formatı en güvenlisidir.
    return {
      'code': code,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'group': group.toString(), // Tüm değerler String olmalı
    };
  }
}