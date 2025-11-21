import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/UserSettings/mikro_user_type.dart';
import '../../models/UserSettings/set_user_mikro_details_command.dart';
import '../../models/UserSettings/user_mikro_details_dto.dart';
import '../../models/UserSettings/user_with_claims.dart';
import '../../services/api/settings_api.dart';
import '../../services/auth_service.dart';
import '../helpers/paginated_search_screen.dart'; 
import '../../models/Helpers/BaseModuleExport.dart';
class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});
  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final SettingsApi _apiService = SettingsApi();
  final AuthService _authService = AuthService();

  bool _isLoadingUsers = true;
  bool _isLoadingDetails = false;
  bool _isSaving = false;

  List<UserWithClaims> _users = [];
  UserWithClaims? _selectedUser;
  
  // API'den gelen orijinal veriyi tutar (kaydetme için)
  UserMikroDetailsDto? _currentDetails; 

  // Form Controller'ları
  final _mikroUserNoController = TextEditingController();
  final _plasiyerCodeController = TextEditingController();
  final _cariCodeController = TextEditingController();
  MikroUserType _selectedUserType = MikroUserType.Standart;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _authService.getUsersList();
      setState(() { _users = users; _isLoadingUsers = false; });
    } catch (e) {
      _showError('Kullanıcılar yüklenemedi: $e');
    }
  }

  // DropdownSearch için arama fonksiyonu
  Future<List<UserWithClaims>> _filterUsers(String filter) async {
    return _users.where((user) => user.userName.toLowerCase().contains(filter.toLowerCase())).toList();
  }

  // Kullanıcı seçildiğinde o kullanıcının detaylarını API'den getiren fonksiyon
  Future<void> _onUserChanged(UserWithClaims? user) async {
    if (user == null) {
      setState(() {
        _selectedUser = null;
        _currentDetails = null;
        _resetFormFields();
      });
      return;
    }
    setState(() { _selectedUser = user; _isLoadingDetails = true; });
    
    try {
      final details = await _apiService.getUserMikroDetails(user.userId);
      setState(() {
        _currentDetails = details;
        _mikroUserNoController.text = details.mikroUserNo.toString();
        _selectedUserType = details.userType;
        _plasiyerCodeController.text = details.plasiyerKodu;
        _cariCodeController.text = details.cariKodu;
        _isLoadingDetails = false;
      });
    } catch (e) {
      _showError('Kullanıcı detayları yüklenemedi: $e');
      setState(() { _isLoadingDetails = false; _resetFormFields(); });
    }
  }

  // Formu temizler
  void _resetFormFields() {
    _mikroUserNoController.clear();
    _plasiyerCodeController.clear();
    _cariCodeController.clear();
    _selectedUserType = MikroUserType.Standart;
  }

  // Hata mesajı göstermek için yardımcı fonksiyon
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // Plasiyer arama ekranını açar
  Future<void> _openPlasiyerSearch() async {
    final result = await Navigator.push<BaseCardViewModel>(
      context,
      MaterialPageRoute(
        builder: (context) => PaginatedSearchScreen(
          title: 'Plasiyer/Temsilci Ara',
          searchType: SearchType.plasiyer, // <-- Artık geçerli bir parametre
          //onSearch: (PaginatedSearchQuery query) => _apiService.searchRepresentatives(query),
        onSearch: (PaginatedSearchQuery query) => _apiService.searchRepresentatives(query),
        ),
      ),
    );
    if (result != null) {
      setState(() => _plasiyerCodeController.text = result.code);
    }
  }

  // Cari/Müşteri arama ekranını açar
  Future<void> _openCariSearch() async {
    final result = await Navigator.push<BaseCardViewModel>(
      context,
      MaterialPageRoute(
        builder: (context) => PaginatedSearchScreen(
          title: 'Cari/Müşteri Ara',
          searchType: SearchType.customer, // <-- Artık geçerli bir parametre
          onSearch: (PaginatedSearchQuery query) => _apiService.searchCustomers(query),
        ),
      ),
    );
    if (result != null) {
      setState(() => _cariCodeController.text = result.code);
    }
  }

  // Formdaki bilgileri API'ye gönderip kaydeder
  Future<void> _saveDetails() async {
    if (_selectedUser == null || _isSaving) return;

    setState(() { _isSaving = true; });

    try {
      final command = SetUserMikroDetailsCommand(
        tokenUserId: _selectedUser!.userId,
        userName: _selectedUser!.userName,
        mikroUserNo: int.tryParse(_mikroUserNoController.text) ?? 0,
        userType: _selectedUserType,
        plasiyerKodu: _plasiyerCodeController.text,
        cariKodu: _cariCodeController.text,
      );
      
      await _apiService.setUserMikroDetails(command);
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayarlar başarıyla kaydedildi!'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      _showError('Kaydedilemedi: $e');
    } finally {
      if(mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Detayları')),
      body: _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Kullanıcı Seçim Dropdown'ı
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownSearch<UserWithClaims>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true, 
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(labelText: 'Kullanıcı adı ara...', border: OutlineInputBorder())
                      )
                    ),
                    asyncItems: _filterUsers,
                    itemAsString: (UserWithClaims user) => user.userName,
                    selectedItem: _selectedUser,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(labelText: 'Kullanıcı Seçin', border: OutlineInputBorder())
                    ),
                    onChanged: _onUserChanged,
                  ),
                ),
                const Divider(height: 1),
                
                // 2. Form Alanı
                Expanded(
                  child: _isLoadingDetails
                      ? const Center(child: CircularProgressIndicator())
                      : _selectedUser == null
                          ? const Center(child: Text('Lütfen bir kullanıcı seçin.'))
                          : _buildDetailForm(),
                ),
              ],
            ),
    );
  }

  // Formun kendisini oluşturan widget
  Widget _buildDetailForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _mikroUserNoController,
            decoration: const InputDecoration(labelText: 'Mikro User No', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MikroUserType>(
            initialValue: _selectedUserType,
            decoration: const InputDecoration(labelText: 'Kullanıcı Tipi', border: OutlineInputBorder()),
            items: MikroUserType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.aStext));
            }).toList(),
            onChanged: (value) => setState(() => _selectedUserType = value!),
          ),
          
          // Koşullu olarak Plasiyer Kodu alanını göster
          if (_selectedUserType == MikroUserType.Plasiyer)
            _buildSearchField('Plasiyer Kodu', _plasiyerCodeController, _openPlasiyerSearch),
          
          // Koşullu olarak Cari Kodu alanını göster
          if (_selectedUserType == MikroUserType.Cari)
            _buildSearchField('Cari Kodu', _cariCodeController, _openCariSearch),
          
          const SizedBox(height: 24),
          
          _isSaving
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _saveDetails,
                  child: const Text('Kaydet'),
                ),
        ],
      ),
    );
  }

  // Devexteki "ButtonEdit" benzeri, tıklanabilir arama kutusu
  Widget _buildSearchField(String label, TextEditingController controller, VoidCallback onSearchPressed) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true, // Sadece arama ile seçilsin
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchPressed,
          ),
        ),
      ),
    );
  }
}