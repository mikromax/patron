import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_config_model.dart';

class ConfigService {
  static const _configsKey = 'api_configs';
  static const _defaultConfigIdKey = 'default_api_config_id';

  // Kayıtlı tüm API yapılandırmalarını getirir
  Future<List<ApiConfig>> getConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final configsString = prefs.getString(_configsKey);
    if (configsString == null) {
      return [];
    }
    final List<dynamic> configsJson = jsonDecode(configsString);
    return configsJson.map((json) => ApiConfig.fromJson(json)).toList();
  }

  // API yapılandırma listesini kaydeder
  Future<void> saveConfigs(List<ApiConfig> configs) async {
    final prefs = await SharedPreferences.getInstance();
    final configsString = jsonEncode(configs.map((config) => config.toJson()).toList());
    await prefs.setString(_configsKey, configsString);
  }

  // Varsayılan API'nin ID'sini getirir
  Future<String?> getDefaultConfigId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultConfigIdKey);
  }

  // Varsayılan API'nin ID'sini kaydeder
  Future<void> saveDefaultConfigId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultConfigIdKey, id);
  }

  // Varsayılan tam API yapılandırmasını getirir
  Future<ApiConfig?> getDefaultConfig() async {
    final id = await getDefaultConfigId();
    if (id == null) return null;
    
    final configs = await getConfigs();
    return configs.firstWhere((config) => config.id == id, orElse: () => configs.first);
  }
}