import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/UserSettings/register_view_model.dart';
import '../../models/UserSettings/user_group_dto.dart';
import '../../models/UserSettings/user_type_enum.dart';
import '../../services/api/auth_api.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthApi _authApi = AuthApi();
  final _formKey = GlobalKey<FormState>();

  // Controller'lar
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _descriptionController = TextEditingController();

  // State Değişkenleri
  bool _isSaving = false;
  bool _isLoadingGroups = true;
  
  UserType _selectedUserType = UserType.Employee;
  bool _isPassive = false;
  UserGroupDto? _selectedGroup;
  List<UserGroupDto> _userGroups = [];

  @override
  void initState() {
    super.initState();
    _loadUserGroups();
  }

  Future<void> _loadUserGroups() async {
    try {
      final groups = await _authApi.searchUserGroups();
      setState(() {
        _userGroups = groups;
        _isLoadingGroups = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gruplar yüklenemedi: $e')));
      }
      setState(() => _isLoadingGroups = false);
    }
  }

  Future<List<UserGroupDto>> _filterGroups(String filter) async {
    return _userGroups.where((g) => 
      g.code.toLowerCase().contains(filter.toLowerCase()) || 
      g.description.toLowerCase().contains(filter.toLowerCase())
    ).toList();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parolalar eşleşmiyor!'), backgroundColor: Colors.red)
      );
      return;
    }

    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kullanıcı grubu seçin.'), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final model = RegisterViewModel(
        userName: _userNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        userGroupId: _selectedGroup!.id,
        description: _descriptionController.text,
        isPassive: _isPassive,
        type: _selectedUserType,
      );

      await _authApi.createUser(model);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı başarıyla oluşturuldu!'), backgroundColor: Colors.green)
        );
        // Formu temizle
        _formKey.currentState?.reset();
        _userNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedGroup = null;
          _selectedUserType = UserType.Employee;
          _isPassive = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Tanımları')),
      body: _isLoadingGroups
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _userNameController,
                      decoration: const InputDecoration(labelText: 'Kullanıcı Adı', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-Posta', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Zorunlu alan';
                        if (!v.contains('@')) return 'Geçersiz email formatı';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(labelText: 'Parola', border: OutlineInputBorder()),
                            obscureText: true,
                            validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(labelText: 'Parola (Tekrar)', border: OutlineInputBorder()),
                            obscureText: true,
                            validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    DropdownSearch<UserGroupDto>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(decoration: InputDecoration(labelText: 'Grup Ara...', border: OutlineInputBorder())),
                      ),
                      asyncItems: _filterUsers, // _filterGroups olmalı, aşağıda düzelttim
                      itemAsString: (UserGroupDto g) => g.display,
                      selectedItem: _selectedGroup,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(labelText: 'Kullanıcı Grubu', border: OutlineInputBorder()),
                      ),
                      onChanged: (val) => setState(() => _selectedGroup = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UserType>(
                      initialValue: _selectedUserType,
                      decoration: const InputDecoration(labelText: 'Kullanıcı Tipi', border: OutlineInputBorder()),
                      items: UserType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.text))).toList(),
                      onChanged: (v) => setState(() => _selectedUserType = v!),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Pasif Kullanıcı'),
                      value: _isPassive,
                      onChanged: (v) => setState(() => _isPassive = v),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _onSave,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                        child: _isSaving ? const CircularProgressIndicator() : const Text('Kullanıcıyı Kaydet'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  // Hata düzeltmesi: asyncItems fonksiyonu
  Future<List<UserGroupDto>> _filterUsers(String filter) async {
    return _filterGroups(filter);
  }
}