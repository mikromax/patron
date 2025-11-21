import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
// Standart Importlar
import '../../models/Helpers/BaseModuleExport.dart';
import '../../services/api/settings_api.dart';
import 'menu_lines_screen.dart'; // Birazdan oluşturacağız

class MenuDefinitionsScreen extends StatefulWidget {
  const MenuDefinitionsScreen({super.key});

  @override
  State<MenuDefinitionsScreen> createState() => _MenuDefinitionsScreenState();
}

class _MenuDefinitionsScreenState extends State<MenuDefinitionsScreen> {
  final SettingsApi _settingsApi = SettingsApi();
  
  // Sayfalama ve Veri State'i
  PaginatedResult<BaseCardViewModel>? _result;
  bool _isLoading = false;
  int _currentPage = 1;
  
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; });
    try {
      // Filtreleri şimdilik boş gönderiyoruz, sadece sayfalama
      final query = PaginatedSearchQuery(pageNumber: _currentPage, pageSize: 20);
      final result = await _settingsApi.searchCustomMenus(query);
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
    if (_result != null && _currentPage < _result!.totalPages) {
      setState(() => _currentPage++);
      _fetchData();
    }
  }
  void _prevPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
      _fetchData();
    }
  }

  // EKLE / DÜZENLE POPUP
  Future<void> _showMenuDialog({BaseCardViewModel? existingItem}) async {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: existingItem?.code ?? '');
    final nameController = TextEditingController(text: existingItem?.description ?? '');
    bool isPassive = existingItem?.isPassive ?? false;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingItem == null ? 'Yeni Menü Şablonu' : 'Menü Düzenle'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: 'Menü Kodu'),
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                      // Düzenlemede kod değiştirilemez olsun isterseniz: readOnly: existingItem != null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Menü Adı'),
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                    ),
                    SwitchListTile(
                      title: const Text('Pasif'),
                      value: isPassive,
                      onChanged: (v) => setDialogState(() => isPassive = v),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setDialogState(() => isSubmitting = true);
                      try {
                        final dto = BaseCardViewModel(
                          id: existingItem?.id ?? const Uuid().v4(), // Yeni ise yeni GUID
                          code: codeController.text,
                          description: nameController.text,
                          isPassive: isPassive,
                        );
                        
                        await _settingsApi.createCustomMenu(dto);
                        
                        if(mounted) {
                          Navigator.pop(context);
                          _fetchData(); // Listeyi yenile
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaydedildi'), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
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
  Future<void> _deleteMenu(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emin misiniz?'),
        content: const Text('Bu menü ve tüm içeriği silinecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hayır')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _settingsApi.deleteCustomMenu(id);
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
      appBar: AppBar(title: const Text('Menü Tanımları')),
      body: Column(
        children: [
          // YENİ MENÜ BUTONU
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Yeni Menü Şablonu'),
                onPressed: () => _showMenuDialog(),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ),
          ),
          
          // LİSTE
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _result == null || _result!.data.isEmpty
                ? const Center(child: Text('Kayıt bulunamadı.'))
                : ListView.builder(
                    itemCount: _result!.data.length,
                    itemBuilder: (context, index) {
                      final item = _result!.data[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(item.code),
                                leading: Icon(item.isPassive ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: 'Düzenle',
                                    onPressed: () => _showMenuDialog(existingItem: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Sil',
                                    onPressed: () => _deleteMenu(item.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.list, color: Colors.indigo),
                                    tooltip: 'Detay (Satırlar)',
                                    // DETAY EKRANINA GİT
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => MenuLinesScreen(menuHeader: item)
                                      ));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.admin_panel_settings, color: Colors.orange),
                                    tooltip: 'Roller',
                                    onPressed: () { /* TODO: Roller */ },
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
          
          // SAYFALAMA
          if (_result != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.navigate_before), onPressed: _currentPage > 1 ? _prevPage : null),
                  Text('Sayfa $_currentPage / ${_result!.totalPages}'),
                  IconButton(icon: const Icon(Icons.navigate_next), onPressed: _currentPage < _result!.totalPages ? _nextPage : null),
                ],
              ),
            ),
        ],
      ),
    );
  }
}