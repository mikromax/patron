import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:patron/models/Helpers/BaseModuleExport.dart';
import '../../models/UserSettings/role_dto.dart';
import '../../models/UserSettings/user_mikro_details_dto.dart';
import '../../models/UserSettings/user_with_claims.dart';
import '../../services/api/settings_api.dart';
import '../../services/auth_service.dart';
class RoleUsersScreen extends StatefulWidget {
  final RoleDto role;
  const RoleUsersScreen({super.key, required this.role});

  @override
  State<RoleUsersScreen> createState() => _RoleUsersScreenState();
}

class _RoleUsersScreenState extends State<RoleUsersScreen> {
  final SettingsApi _settingsApi = SettingsApi();
  final AuthService _authService = AuthService();// Kullanıcı listesi için

  PaginatedResult<UserMikroDetailsDto>? _result;
  bool _isLoading = false;
  final PaginatedSearchQuery _currentQuery = PaginatedSearchQuery(pageSize: 20);
  List<String> _selectedUserIds = []; // Toplu silme için seçilenler

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _selectedUserIds = []; });
    try {
      final result = await _settingsApi.getUsersInRole(widget.role.id, _currentQuery);
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

  // KULLANICI EKLEME DİYALOGU
Future<void> _showAddUserDialog() async {
    UserWithClaims? selectedUser;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // Yanlışlıkla kapanmasın
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Kullanıcı Ekle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownSearch<UserWithClaims>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(labelText: 'Ara...', border: OutlineInputBorder())
                      ),
                    ),
                    // --- DÜZELTME BURADA: ARTIK BOŞ LİSTE DÖNMÜYOR ---
                    asyncItems: (filter) async {
                      // 1. Tüm kullanıcıları çek
                      var allUsers = await _authService.getUsersList();
                      
                      // 2. Eğer arama metni varsa filtrele
                      if (filter.isNotEmpty) {
                        return allUsers.where((u) => 
                          u.userName.toLowerCase().contains(filter.toLowerCase())
                        ).toList();
                      }
                      return allUsers;
                    },
                    itemAsString: (u) => u.userName,
                    onChanged: (u) => setDialogState(() => selectedUser = u),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(labelText: 'Kullanıcı Seç')
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext), 
                  child: const Text('İptal')
                ),
                ElevatedButton(
                  onPressed: (isSubmitting || selectedUser == null) ? null : () async {
                    setDialogState(() => isSubmitting = true);
                    try {
                      // API Çağrısı
                      await _settingsApi.addUsersToRole(widget.role.id, [selectedUser!.userId]);
                      
                      if(mounted) {
                        Navigator.pop(dialogContext); // Dialogu kapat
                        _fetchData(); // Ana listeyi yenile
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kullanıcı eklendi'), backgroundColor: Colors.green)
                        );
                      }
                    } catch(e) {
                      setDialogState(() => isSubmitting = false);
                      // Hata mesajını ana context üzerinden gösteriyoruz (mounted kontrolüyle)
                      if (mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: const Text('Ekle'),
                ),
              ],
            );
          }
        );
      }
    );
  }
  // KULLANICI SİLME (ÇIKARMA)
  Future<void> _removeUsers() async {
    if (_selectedUserIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emin misiniz?'),
        content: Text('${_selectedUserIds.length} kullanıcı rolden çıkarılacak.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hayır')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _settingsApi.removeUsersFromRole(widget.role.id, _selectedUserIds);
        _fetchData();
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Çıkarıldı'), backgroundColor: Colors.green));
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // AuthServicce örneği oluştur (Kullanıcı listesi için)
    // _showAddUserDialog içinde bunu kullanacağız
    
    return Scaffold(
      appBar: AppBar(title: Text('${widget.role.description} - Kullanıcılar')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (_selectedUserIds.isNotEmpty)
            Container(
              color: Colors.red.shade50,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text('${_selectedUserIds.length} kişi seçildi'),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Seçilenleri Çıkar', style: TextStyle(color: Colors.red)),
                    onPressed: _removeUsers,
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _result == null || _result!.data.isEmpty
                ? const Center(child: Text('Bu rolde kullanıcı yok.'))
                : ListView.builder(
                    itemCount: _result!.data.length,
                    itemBuilder: (context, index) {
                      final user = _result!.data[index];
                      final isSelected = _selectedUserIds.contains(user.tokenUserId);
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(user.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user.tokenUserId),
                        secondary: const Icon(Icons.person),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedUserIds.add(user.tokenUserId);
                            } else {
                              _selectedUserIds.remove(user.tokenUserId);
                            }
                          });
                        },
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