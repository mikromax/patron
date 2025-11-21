import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/Helpers/base_card_view_model.dart';
import '../../models/Auth/session_details_dto.dart';
import '../../services/auth_service.dart';

class ContextSwitchScreen extends StatefulWidget {
  const ContextSwitchScreen({super.key});

  @override
  State<ContextSwitchScreen> createState() => _ContextSwitchScreenState();
}

class _ContextSwitchScreenState extends State<ContextSwitchScreen> {
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isSaving = false;

  // Form verileri
  List<BaseCardViewModel> _allFirms = [];
  List<BaseCardViewModel> _allFacilities = [];
  
  // Seçili değerler
  BaseCardViewModel? _selectedFirm;
  BaseCardViewModel? _selectedFacility;
  
  // API'den gelen o anki bağlam
  SessionDetailsDto? _currentContext;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() { _isLoading = true; });
    try {
      // 1. O anki bağlamı ve tüm firmaları aynı anda çek
      final contextFuture = _authService.getCurrentContext();
      final firmsFuture = _authService.getAllFirms();

      final context = await contextFuture;
      final firms = await firmsFuture;

      _currentContext = context;
      _allFirms = firms;

      // 2. O anki firma seçiliyse, ona ait tesisleri de çek
      if (context?.currentFirmId != null) {
        _selectedFirm = firms.firstWhere((f) => f.id == context!.currentFirmId, orElse: () => firms.first);
        
        final facilities = await _authService.getFacilitiesForFirm(_selectedFirm!.id);
        _allFacilities = facilities;
        
        if (context?.currentFacilityId != null) {
          _selectedFacility = facilities.firstWhere((f) => f.id == context!.currentFacilityId, orElse: () => facilities.first);
        }
      }

      setState(() { _isLoading = false; });
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      setState(() { _isLoading = false; });
    }
  }

  // Kullanıcı Dropdown'dan bir FİRMA seçtiğinde
  Future<void> _onFirmChanged(BaseCardViewModel? firm) async {
    if (firm == null) return;
    
    setState(() {
      _selectedFirm = firm;
      _isLoading = true; // Tesisler yükleniyor...
      _allFacilities = []; // Tesis listesini temizle
      _selectedFacility = null; // Tesis seçimini temizle
    });

    try {
      final facilities = await _authService.getFacilitiesForFirm(firm.id);
      setState(() {
        _allFacilities = facilities;
        if(facilities.isNotEmpty) {
          _selectedFacility = facilities.first; // Varsayılan olarak ilk tesisi seç
        }
        _isLoading = false;
      });
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tesisler yüklenemedi: $e'), backgroundColor: Colors.red));
      setState(() { _isLoading = false; });
    }
  }

  // "Değiştir" butonuna basıldığında
  Future<void> _onChangeContext() async {
    if (_selectedFirm == null || _selectedFacility == null || _isSaving) return;
    
    setState(() { _isSaving = true; });

    try {
      // 1. API'ye git ve yeni session'ı al
      await _authService.changeCurrentContext(_selectedFirm!.id, _selectedFacility!.id);

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bağlam başarıyla değiştirildi!'), backgroundColor: Colors.green)
        );
        // Ana Menü'ye veya Ana Sayfa'ya geri dön
        Navigator.pop(context, true); // true = "Yenileme gerekli"
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      setState(() { _isSaving = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firma / Tesis Seçimi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 1. Firma Seçimi
                  DropdownSearch<BaseCardViewModel>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: _allFirms,
                    itemAsString: (item) => item.description,
                    selectedItem: _selectedFirm,
                    onChanged: _onFirmChanged,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(labelText: 'Firma Seçin', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 2. Tesis Seçimi
                  DropdownSearch<BaseCardViewModel>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: _allFacilities,
                    itemAsString: (item) => item.description,
                    selectedItem: _selectedFacility,
                    onChanged: (val) => setState(() => _selectedFacility = val),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(labelText: 'Tesis Seçin', border: OutlineInputBorder()),
                    ),
                    // Firma seçilmeden tesis seçilemez
                    enabled: _selectedFirm != null,
                  ),
                  const SizedBox(height: 24),

                  // 3. Kaydet Butonu
                  _isSaving
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onChangeContext,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                            child: const Text('Değiştir'),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}