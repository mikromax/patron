import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/UserSettings/user_with_claims.dart';
import '../../models/UserSettings/user_widget_dto.dart';
import '../../models/UserSettings/set_user_widget_settings_command.dart';
import '../../services/api/settings_api.dart';
import '../../services/auth_service.dart';

class WidgetSettingsScreen extends StatefulWidget {
  const WidgetSettingsScreen({super.key});
  @override
  State<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends State<WidgetSettingsScreen> {
  final SettingsApi _apiService = SettingsApi();
  final AuthService _authService = AuthService();

  bool _isLoadingUsers = true;
  bool _isLoadingWidgets = false;
  bool _isSaving = false;

  List<UserWithClaims> _users = [];
  UserWithClaims? _selectedUser;
  List<UserWidgetDto> _userWidgets = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _authService.getUsersList();
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kullanıcılar yüklenemedi: $e')));
      }
    }
  }

  // DropdownSearch v5.x için arama fonksiyonu
  Future<List<UserWithClaims>> _filterUsers(String filter) async {
    var filteredList = _users.where((user) {
      return user.userName.toLowerCase().contains(filter.toLowerCase());
    }).toList();
    
    return filteredList;
  }

  Future<void> _onUserChanged(UserWithClaims? user) async {
    if (user == null) return;
    setState(() {
      _selectedUser = user;
      _userWidgets = [];
      _isLoadingWidgets = true;
    });

    try {
      final widgets = await _apiService.getWidgetsForUser(user.userId);
      setState(() {
        _userWidgets = widgets..sort((a,b) => a.sortOrder.compareTo(b.sortOrder));
        _isLoadingWidgets = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Widget\'lar yüklenemedi: $e')));
      }
      setState(() { _isLoadingWidgets = false; });
    }
  }

  Future<void> _onSaveSettings() async {
    if (_selectedUser == null || _isSaving) return;
    setState(() { _isSaving = true; });

    try {
      final command = SetUserWidgetSettingsCommand(
        tokenUserId: _selectedUser!.userId,
        widgetSettings: _userWidgets,
      );
      await _apiService.setWidgetsForUser(command);
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayarlar başarıyla kaydedildi!'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kaydedilemedi: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if(mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Ayarları')),
      body: _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  // v5.0.6 (en güncel) için doğru syntax
                  child: DropdownSearch<UserWithClaims>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'Kullanıcı adı ara...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    
                    asyncItems: _filterUsers,

                    itemAsString: (UserWithClaims user) => user.userName,
                    selectedItem: _selectedUser,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Kullanıcı Seçin',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: _onUserChanged,
                  ),
                ),
                const Divider(height: 1),
                
                // --- DÜZELTME BURADA: Expanded eklendi ---
                // Bu widget, ListView'a sabit bir alan vererek 
                // "sonsuz yükseklik" hatasını ve donmayı engeller.
                Expanded(
                  child: _buildWidgetList(),
                ),
                
                // Kaydet butonu
                if (_userWidgets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onSaveSettings,
                              child: const Text('Kaydet'),
                            ),
                          ),
                  ),
              ],
            ),
    );
  }

  Widget _buildWidgetList() {
    if (_selectedUser == null) return const Center(child: Text('Lütfen bir kullanıcı seçin.'));
    if (_isLoadingWidgets) return const Center(child: CircularProgressIndicator());
    if (_userWidgets.isEmpty) return const Center(child: Text('Bu kullanıcı için widget ayarı bulunamadı.'));

    return ReorderableListView.builder(
      itemCount: _userWidgets.length,
      itemBuilder: (context, index) {
        final widgetSetting = _userWidgets[index];
        return Card(
          key: ValueKey(widgetSetting.id),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(widgetSetting.widgetId),
            leading: Text("${widgetSetting.sortOrder}"),
            trailing: Switch(
              value: widgetSetting.isVisible,
              onChanged: (newValue) {
                setState(() {
                  _userWidgets[index].isVisible = newValue;
                });
              },
            ),
          ),
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final UserWidgetDto item = _userWidgets.removeAt(oldIndex);
          _userWidgets.insert(newIndex, item);
          
          for (int i = 0; i < _userWidgets.length; i++) {
            _userWidgets[i].sortOrder = i;
          }
        });
      },
    );
  }
}