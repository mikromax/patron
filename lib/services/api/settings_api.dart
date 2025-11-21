import 'package:dio/dio.dart';
import '../../models/result_model.dart';
// Modeller
import '../../models/UserSettings/user_menu_dto.dart';
import '../../models/UserSettings/add_custom_menu_item_command.dart';
import '../../models/UserSettings/user_widget_dto.dart';
import '../../models/UserSettings/set_user_widget_settings_command.dart';
import '../../models/UserSettings/user_mikro_details_dto.dart';
import '../../models/UserSettings/set_user_mikro_details_command.dart';
import '../../models/Helpers/base_card_view_model.dart';
import '../../models/Helpers/paginated_search_query.dart';
import '../../models/Helpers/paginated_result.dart';
import '../../models/UserSettings/program_definition_dto.dart';
import '../../models/Attachments/entity_type_dto.dart';
import '../../models/Attachments/required_document_dto.dart';
import '../../models/Attachments/document_type_rule_dto.dart';
import '../../models/Helpers/document_sequence_type.dart';
import '../../models/UserSettings/create_custom_menu_item_dto.dart';
import '../../models/UserSettings/role_dto.dart';
// Motor
import 'core/api_client.dart';

class SettingsApi {
  final Dio _dio = ApiClient().dio;

  // --- MENÜ İŞLEMLERİ ---

  Future<List<UserMenuDto>> getUserMenu() async {
    try {
      final response = await _dio.get('api/UserSettings/menu');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => UserMenuDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
  // YENİ METOT: Tüm Aktif Para Birimlerini Getir (Lookup)
  Future<List<BaseCardViewModel>> getCurrenciesLookup() async {
    try {
      final response = await _dio.get('api/currencies/lookup');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => BaseCardViewModel.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // YENİ METOT: Tüm Aktif Ülkeleri Getir (Lookup)
  Future<List<BaseCardViewModel>> getCountriesLookup() async {
    try {
      final response = await _dio.get('api/countries/lookup');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => BaseCardViewModel.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
  // YENİ METOT: Para Birimlerini Arar
  Future<PaginatedResult<BaseCardViewModel>> searchCurrencies(PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/currencies',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedResult.fromJson(resultModel.result!, (json) => BaseCardViewModel.fromJson(json));
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
// YENİ METOT: Ülkeleri Arar
  Future<PaginatedResult<BaseCardViewModel>> searchCountries(PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/countries',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedResult.fromJson(resultModel.result!, (json) => BaseCardViewModel.fromJson(json));
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
  Future<UserMenuDto> addMenuItem(AddCustomMenuItemCommand command) async {
    try {
      final response = await _dio.post(
        'api/UserSettings/menuadd',
        data: command.toJson(),
      );
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return UserMenuDto.fromJson(resultModel.result!);
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // --- WIDGET İŞLEMLERİ ---

  Future<List<UserWidgetDto>> getUserWidgetPermissions() async {
    try {
      final response = await _dio.get('api/UserSettings/widgets_get');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => UserWidgetDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<List<UserWidgetDto>> getWidgetsForUser(String userId) async {
    try {
      final response = await _dio.get('api/usersettings/widgets/$userId');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => UserWidgetDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<bool> setWidgetsForUser(SetUserWidgetSettingsCommand command) async {
    try {
      final response = await _dio.post(
        'api/usersettings/widgets/user',
        data: command.toJson(),
      );
      final resultModel = ResultModel<bool>.fromJson(response.data);
      return resultModel.isSuccessful && (resultModel.result ?? true);
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // --- KULLANICI MİKRO DETAYLARI ---

  Future<UserMikroDetailsDto> getUserMikroDetails(String userId) async {
    try {
      final response = await _dio.get('api/usersettings/mikrodetails/$userId');
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return UserMikroDetailsDto.fromJson(resultModel.result!);
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<bool> setUserMikroDetails(SetUserMikroDetailsCommand command) async {
    try {
      final response = await _dio.post(
        'api/usersettings/mikrodetails',
        data: command.toJson(),
      );
      final resultModel = ResultModel<String>.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // --- ARAMA İŞLEMLERİ (CARİ / PLASİYER) ---

  Future<PaginatedResult<BaseCardViewModel>> searchCustomers(PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/Search/customers',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedResult.fromJson(resultModel.result!, (json) => BaseCardViewModel.fromJson(json));
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<PaginatedResult<BaseCardViewModel>> searchRepresentatives(PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/search/representatives',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedResult.fromJson(resultModel.result!, (json) => BaseCardViewModel.fromJson(json));
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // --- DİĞER TANIMLAMALAR ---

  Future<List<ProgramDefinitionDto>> getAllAvailablePrograms() async {
    try {
      final response = await _dio.get('api/UserSettings/programs/all');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => ProgramDefinitionDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<List<EntityTypeDto>> getAttachableEntityTypes() async {
    try {
      final response = await _dio.get('api/attachments/attachable-entities');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => EntityTypeDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<List<RequiredDocumentDto>> getDocumentTypeRules(String entityName, String entityId) async {
    try {
      final response = await _dio.get(
        'api/attachments/rules',
        queryParameters: {
          'entityName': entityName,
          'entityId': entityId,
        },
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => RequiredDocumentDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<String> setDocumentTypeRule(DocumentTypeRuleDto ruleDto) async {
    try {
      final response = await _dio.post(
        'api/attachments/setrules',
        data: ruleDto.toJson(),
      );
      final resultModel = ResultModel<String>.fromJson(response.data);
      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!;
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<String> getNextDocumentNumber(DocumentSequenceType documentType) async {
    try {
      final response = await _dio.get(
        'api/usersettings/next-document-number',
        queryParameters: {'documentType': documentType.value.toString()},
      );
      final resultModel = ResultModel<String>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!;
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
  Future<PaginatedResult<BaseCardViewModel>> searchCustomMenus(PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/usersettings/custom-menus',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedResult.fromJson(resultModel.result!, (json) => BaseCardViewModel.fromJson(json));
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 2. Menü Şablonu Oluştur/Güncelle (BaseCardViewModel kullanıyor)
  Future<bool> createCustomMenu(BaseCardViewModel dto) async {
    try {
      final response = await _dio.post(
        'api/usersettings/custom-menus',
        data: dto.toJson(),
      );
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 3. Menü Şablonu Sil
  Future<bool> deleteCustomMenu(String id) async {
    try {
      final response = await _dio.delete('api/usersettings/custom-menus/$id');
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // --- MENÜ SATIRLARI (ITEMS) ---

  // 4. Menü Satırlarını Getir
  Future<List<UserMenuDto>> getCustomMenuItems(String customMenuId) async {
    try {
      final response = await _dio.get('api/usersettings/custom-menus/$customMenuId/items');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => UserMenuDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 5. Menü Satırı Ekle
  Future<bool> addMenuItemToCustomMenu(CreateCustomMenuItemDto dto) async {
    try {
      final response = await _dio.post(
        'api/usersettings/custom-menu-items',
        data: dto.toJson(),
      );
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 6. Menü Satırı Sil
  Future<bool> deleteMenuItemFromCustomMenu(String id) async {
    try {
      final response = await _dio.delete('api/usersettings/custom-menu-items/$id');
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
  Future<PaginatedResult<RoleDto>> searchRoles(PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/roles',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedResult.fromJson(resultModel.result!, (json) => RoleDto.fromJson(json));
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 2. Rol Oluştur
  Future<bool> createRole(RoleDto dto) async {
    try {
      final response = await _dio.post('api/roles', data: dto.toJson());
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 3. Rol Güncelle
  Future<bool> updateRole(RoleDto dto) async {
    try {
      final response = await _dio.put('api/roles/${dto.id}', data: dto.toJson());
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 4. Rol Sil
  Future<bool> deleteRole(String id) async {
    try {
      final response = await _dio.delete('api/roles/$id');
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // --- ROL KULLANICILARI ---

  // 5. Roldeki Kullanıcıları Getir
  Future<PaginatedResult<UserMikroDetailsDto>> getUsersInRole(String roleId, PaginatedSearchQuery query) async {
    try {
      final response = await _dio.get(
        'api/roles/$roleId/users',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<Map<String, dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return PaginatedResult.fromJson(resultModel.result!, (json) => UserMikroDetailsDto.fromJson(json));
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 6. Role Kullanıcı Ekle (Toplu)
  Future<bool> addUsersToRole(String roleId, List<String> userIds) async {
    try {
      final response = await _dio.post('api/roles/$roleId/users', data: userIds);
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 7. Rolden Kullanıcı Çıkar (Toplu)
  Future<bool> removeUsersFromRole(String roleId, List<String> userIds) async {
    try {
      // DELETE metodunda body göndermek için 'data' parametresini kullanıyoruz
      final response = await _dio.delete('api/roles/$roleId/users', data: userIds);
      final resultModel = ResultModel.fromJson(response.data);
      return resultModel.isSuccessful;
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}