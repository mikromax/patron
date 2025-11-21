// lib/models/add_custom_menu_item_command.dart
import 'create_user_menu_dto.dart';

class AddCustomMenuItemCommand {
  final String tokenUserId;
  final CreateUserMenuDto menuData;

  AddCustomMenuItemCommand({required this.tokenUserId, required this.menuData});

  Map<String, dynamic> toJson() {
    return {
      'TokenUserId': tokenUserId,
      'MenuData': menuData.toJson(),
    };
  }
}