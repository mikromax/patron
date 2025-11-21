// lib/models/credit_limit_request_types.dart
enum CreditLimitRequestTypes {
  TemporaryAdditionalLimit(0, "Geçici İlave Limit"),
  PermanentLimitIncrease(1, "Kalıcı Limit Artışı");

  final int value;
  final String text;
  const CreditLimitRequestTypes(this.value, this.text);

  // int'ten enum'a çevirmek için
  factory CreditLimitRequestTypes.fromValue(int value) {
    return values.firstWhere((e) => e.value == value, 
      orElse: () => TemporaryAdditionalLimit);
  }
}