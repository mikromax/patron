class ResultModel<T> {
  final T? result;
  final bool isSuccessful;
  final List<String> errors;

  ResultModel({
    this.result,
    required this.isSuccessful,
    required this.errors,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    // Gelen JSON'daki 'errors' listesini doğru şekilde List<String>'e çeviriyoruz.
    var errorsFromJson = json['errors'] as List<dynamic>?;
    List<String> errorList = errorsFromJson?.map((e) => e.toString()).toList() ?? [];

    return ResultModel<T>(
      // 'result' alanı null olabilir, bu yüzden kontrol ediyoruz.
      result: json.containsKey('result') ? json['result'] as T : null,
      isSuccessful: json['isSuccessful'],
      errors: errorList,
    );
  }
}