// lib/models/UserSettings/set_user_widget_settings_command.dart
import 'user_widget_dto.dart';

class SetUserWidgetSettingsCommand {
  final String tokenUserId;
  final List<UserWidgetDto> widgetSettings;

  SetUserWidgetSettingsCommand({
    required this.tokenUserId,
    required this.widgetSettings,
  });

  Map<String, dynamic> toJson() {
    return {
      'TokenUserId': tokenUserId,
      'WidgetSettings': widgetSettings.map((w) => w.toJson()).toList(),
    };
  }
}