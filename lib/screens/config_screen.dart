import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/api_config_model.dart';
import '../services/config_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final ConfigService _configService = ConfigService();
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _urlController = TextEditingController();
  final Uuid _uuid = const Uuid();

  List<ApiConfig> _configs = [];
  String? _defaultConfigId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    setState(() {
      _isLoading = true;
    });
    _configs = await _configService.getConfigs();
    _defaultConfigId = await _configService.getDefaultConfigId();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showConfigDialog({ApiConfig? existingConfig}) async {
    if (existingConfig != null) {
      _nicknameController.text = existingConfig.nickname;
      _urlController.text = existingConfig.url;
    } else {
      _nicknameController.clear();
      _urlController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingConfig == null ? 'Yeni API Ekle' : 'API Düzenle'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(labelText: 'Takma Ad (Örn: Prod Server)'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Bu alan boş olamaz' : null,
                ),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'Root API Adresi (URL)'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Bu alan boş olamaz' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (existingConfig == null) {
                    final newConfig = ApiConfig(
                      id: _uuid.v4(),
                      nickname: _nicknameController.text,
                      url: _urlController.text,
                    );
                    _configs.add(newConfig);
                  } else {
                    final index = _configs.indexWhere((c) => c.id == existingConfig.id);
                    if (index != -1) {
                      _configs[index].nickname = _nicknameController.text;
                      _configs[index].url = _urlController.text;
                    }
                  }
                  await _configService.saveConfigs(_configs);
                  // Eğer eklenen ilk ayar ise, otomatik olarak varsayılan yapalım
                  if (_configs.length == 1) {
                     await _setDefaultConfig(_configs.first.id);
                  } else {
                    await _loadConfigs();
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteConfig(String id) async {
    _configs.removeWhere((config) => config.id == id);
    if (_defaultConfigId == id) {
      _defaultConfigId = null;
      // Varsayılan ID'yi temizliyoruz
      await _configService.saveDefaultConfigId('');
    }
    await _configService.saveConfigs(_configs);
    await _loadConfigs();
  }

  Future<void> _setDefaultConfig(String id) async {
    await _configService.saveDefaultConfigId(id);
    await _loadConfigs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Yapılandırması'),
        backgroundColor: Colors.indigo,
        // --- YENİ EKLENEN BÖLÜM ---
        actions: [
          // Eğer bir varsayılan API seçilmişse "Bitti" butonunu göster
          if (_defaultConfigId != null && _defaultConfigId!.isNotEmpty)
            TextButton(
              onPressed: () {
                // Ana sayfaya yönlendir ve ayarlar sayfasını yığından kaldır.
                // Bu, ana sayfadan geri tuşuna basınca tekrar buraya gelinmesini engeller.
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text(
                'Bitti',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _configs.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Hiç API yapılandırması bulunamadı.\nLütfen sağ alttaki (+) butonu ile yeni bir tane ekleyin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _configs.length,
                  itemBuilder: (context, index) {
                    final config = _configs[index];
                    final isDefault = config.id == _defaultConfigId;
                    return Card(
                      color: isDefault ? Colors.indigo.shade50 : null,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          Icons.dns,
                          color: isDefault ? Colors.indigo : Colors.grey,
                        ),
                        title: Text(
                          config.nickname,
                          style: TextStyle(
                            fontWeight: isDefault ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(config.url),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'default') {
                              _setDefaultConfig(config.id);
                            } else if (value == 'edit') {
                              _showConfigDialog(existingConfig: config);
                            } else if (value == 'delete') {
                              _deleteConfig(config.id);
                            }
                          },
                          itemBuilder: (context) => [
                            if (!isDefault)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Varsayılan Yap'),
                              ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Düzenle'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Sil'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showConfigDialog(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}