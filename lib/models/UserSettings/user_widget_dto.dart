// lib/models/UserSettings/user_widget_dto.dart
class UserWidgetDto {
  String id;
  String widgetId;
  bool isVisible;
  int sortOrder;

  UserWidgetDto({
    required this.id,
    required this.widgetId,
    required this.isVisible,
    required this.sortOrder,
  });

  factory UserWidgetDto.fromJson(Map<String, dynamic> json) {
    return UserWidgetDto(
      id: json['id'] as String,
      widgetId: json['widgetId'] as String,
      isVisible: json['isVisible'] as bool,
      sortOrder: json['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'widgetId': widgetId,
      'isVisible': isVisible,
      'sortOrder': sortOrder,
    };
  }
}