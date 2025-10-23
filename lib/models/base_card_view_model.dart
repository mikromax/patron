// lib/models/base_card_view_model.dart
class BaseCardViewModel {
  final String id;
  final String code;
  final String description;
  final bool isPassive;

  BaseCardViewModel({
    required this.id,
    required this.code,
    required this.description,
    required this.isPassive,
  });

  factory BaseCardViewModel.fromJson(Map<String, dynamic> json) {
    return BaseCardViewModel(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      isPassive: json['isPassive'] as bool,
    );
  }
}