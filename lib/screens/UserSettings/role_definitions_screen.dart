import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:patron/models/Helpers/BaseModuleExport.dart'; // BaseCardViewModel vb. için
import '../../models/UserSettings/role_dto.dart';
import '../../services/api/settings_api.dart';
import '../helpers/paginated_search_screen.dart'; // Menü seçimi için
import 'role_users_screen.dart'; // Birazdan oluşturacağız

class RoleDefinitionsScreen extends StatefulWidget {
  const RoleDefinitionsScreen({super.key});

  @override
  State<RoleDefinitionsScreen> createState() => _RoleDefinitionsScreenState();
}

class _RoleDefinitionsScreenState extends State<RoleDefinitionsScreen> {
  final SettingsApi _settingsApi = SettingsApi();
  
  PaginatedResult<RoleDto>? _result;
  bool _isLoading = false;
  final PaginatedSearchQuery _currentQuery = PaginatedSearchQuery(pageSize: 20);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; });
    try {
      final result = await _settingsApi.searchRoles(_currentQuery);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      setState(() { _isLoading = false; });
    }
  }

  void _nextPage() {
    if (_result != null && _currentQuery.pageNumber < _result!.totalPages) {
      setState(() => _currentQuery.pageNumber++);
      _fetchData();
    }
  }
  
  void _prevPage() {
    if (_currentQuery.pageNumber > 1) {
      setState(() => _currentQuery.pageNumber--);
      _fetchData();
    }
  }


  Future<void> _showRoleDialog({RoleDto? existingRole}) async {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: existingRole?.code ?? '');
    final descController = TextEditingController(text: existingRole?.description ?? '');
    // Menu adı ve ID'si için yerel değişkenler
    final menuController = TextEditingController(text: existingRole?.customMenuName ?? '');
    String? selectedMenuId = existingRole?.customMenuId;
    
    bool isPassive = existingRole?.isPassive ?? false;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // 1. DÜZELTME: Yanlışlıkla kapanmayı engelle
      // 2. DÜZELTME: context ismini 'dialogContext' yaptık
      builder: (dialogContext) { 
        return StatefulBuilder(
          builder: (innerContext, setDialogState) {
            return AlertDialog(
              title: Text(existingRole == null ? 'Yeni Rol' : 'Rolü Düzenle'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: codeController,
                        decoration: const InputDecoration(labelText: 'Rol Kodu'),
                        validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Açıklama'),
                        validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                      ),
                      const SizedBox(height: 10),
                      
                      // MENÜ SEÇİM ALANI
                      TextFormField(
                        controller: menuController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Bağlı Menü',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () async {
                              // 3. DÜZELTME: Navigator.push için 'dialogContext' kullanıyoruz
                              // Böylece dialogun üzerine açılıyor
                              final result = await Navigator.push<BaseCardViewModel>(
                                dialogContext,
                                MaterialPageRoute(
                                  builder: (context) => PaginatedSearchScreen(
                                    title: 'Menü Ara',
                                    searchType: SearchType.other,
                                    onSearch: (query) => _settingsApi.searchCustomMenus(query),
                                  ),
                                ),
                              );

                              // Arama ekranı kapandıktan sonra burası çalışır
                              // Dialog hala açık olmalı.
                              if (result != null) {
                                setDialogState(() {
                                  selectedMenuId = result.id;
                                  menuController.text = result.description; // Veya result.code
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Pasif'),
                        value: isPassive,
                        onChanged: (v) => setDialogState(() => isPassive = v),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  // Dialogu kapatmak için 'dialogContext' kullan
                  onPressed: () => Navigator.pop(dialogContext), 
                  child: const Text('İptal')
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setDialogState(() => isSubmitting = true);
                      try {
                        final dto = RoleDto(
                          id: existingRole?.id ?? const Uuid().v4(),
                          code: codeController.text,
                          description: descController.text,
                          isPassive: isPassive,
                          customMenuId: selectedMenuId,
                          customMenuName: menuController.text,
                        );
                        
                        if (existingRole == null) {
                          await _settingsApi.createRole(dto);
                        } else {
                          await _settingsApi.updateRole(dto);
                        }
                        
                        if(mounted) {
                          Navigator.pop(dialogContext); // İşlem bitince kapat
                          _fetchData(); 
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaydedildi'), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        // Hata mesajını ana context üzerinden göster
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // SİLME İŞLEMİ
  Future<void> _deleteRole(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emin misiniz?'),
        content: const Text('Bu rol silinecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hayır')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _settingsApi.deleteRole(id);
        _fetchData();
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silindi'), backgroundColor: Colors.green));
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rol Tanımları')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Yeni Rol'),
                onPressed: () => _showRoleDialog(),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _result == null || _result!.data.isEmpty
                ? const Center(child: Text('Kayıt bulunamadı.'))
                : ListView.builder(
                    itemCount: _result!.data.length,
                    itemBuilder: (context, index) {
                      final role = _result!.data[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(role.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${role.code}\nMenü: ${role.customMenuName ?? "-"}'),
                                isThreeLine: true,
                                leading: Icon(role.isPassive ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: 'Düzenle',
                                    onPressed: () => _showRoleDialog(existingRole: role),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Sil',
                                    onPressed: () => _deleteRole(role.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.people, color: Colors.indigo),
                                    tooltip: 'Kullanıcılar',
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => RoleUsersScreen(role: role)
                                      ));
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_result != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.navigate_before), onPressed: _currentQuery.pageNumber > 1 ? _prevPage : null),
                  Text('Sayfa ${_currentQuery.pageNumber} / ${_result!.totalPages}'),
                  IconButton(icon: const Icon(Icons.navigate_next), onPressed: _currentQuery.pageNumber < _result!.totalPages ? _nextPage : null),
                ],
              ),
            ),
        ],
      ),
    );
  }
}