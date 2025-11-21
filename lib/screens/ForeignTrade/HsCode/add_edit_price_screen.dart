import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
// Gerekli servisleri ve modelleri import ediyoruz
import '../../../models/Helpers/base_card_view_model.dart';
import '../../../models/ForeignTrade/HsCode/hs_code_reference_price_dto.dart';
import '../../../models/ForeignTrade/HsCode/create_reference_price_dto.dart';
import '../../../models/ForeignTrade/HsCode/update_reference_price_dto.dart';
import '../../../models/ForeignTrade/HsCode/price_unit_type.dart';
import '../../../models/ForeignTrade/HsCode/reference_price_scope_type.dart';
import '../../../services/api/settings_api.dart';
import '../../../services/api/ForeignTrade/hscode_api.dart';
import '../../../services/auth_service.dart'; // Varsayılan para birimi için
import '../../../models/Auth/session_details_dto.dart';




class AddEditPriceScreen extends StatefulWidget {
  final String hsCodeId;
  final HsCodeReferencePriceDto? existingPrice;

  const AddEditPriceScreen({
    super.key,
    required this.hsCodeId,
    this.existingPrice,
  });

  bool get isEditing => existingPrice != null;

  @override
  State<AddEditPriceScreen> createState() => _AddEditPriceScreenState();
}

class _AddEditPriceScreenState extends State<AddEditPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _settingsApi = SettingsApi();
  final _hsCodeApi = HsCodeApi();
  final _authService = AuthService();

  bool _isSaving = false;
  bool _isLookupsLoading = true;

  final _priceController = TextEditingController();
  late DateTime _selectedStartDate;
  
  List<BaseCardViewModel> _currencies = [];
  List<BaseCardViewModel> _countries = [];

  BaseCardViewModel? _selectedCurrency;
  PriceUnitType _selectedUnitType = PriceUnitType.Quantity;
  ReferencePriceScopeType _selectedScopeType = ReferencePriceScopeType.AllCountries;
  List<BaseCardViewModel> _selectedCountries = [];

  @override
  void initState() {
    super.initState();
    _loadLookups();
    _selectedStartDate = widget.isEditing ? widget.existingPrice!.startDate : DateTime.now();
    if (widget.isEditing) {
      _priceController.text = widget.existingPrice!.price.toString();
      _selectedUnitType = widget.existingPrice!.priceUnitType;
      _selectedScopeType = widget.existingPrice!.scopeType;
    }
  }

  // --- YENİ YARDIMCI FONKSİYON ---
  // firstWhere'in null döndürmesine izin veren güvenli bir versiyonu
  BaseCardViewModel? _tryFirstWhere(List<BaseCardViewModel> list, bool Function(BaseCardViewModel) test) {
    try {
      return list.firstWhere(test);
    } catch (e) {
      // Eşleşme bulunamazsa (veya liste boşsa) firstWhere hata fırlatır
      return null;
    }
  }

  // --- GÜNCELLENMİŞ LOOKUP YÜKLEME FONKSİYONU ---
  Future<void> _loadLookups() async {
    try {
      final contextFuture = _authService.getCurrentContext();
      final currencyFuture = _settingsApi.getCurrenciesLookup(); 
      final countryFuture = _settingsApi.getCountriesLookup();

      final results = await Future.wait([contextFuture, currencyFuture, countryFuture]);
      
      final context = results[0] as SessionDetailsDto?;
      final currencyResult = results[1] as List<BaseCardViewModel>;
      final countryResult = results[2] as List<BaseCardViewModel>;
      
      final String? defaultCurrencyCode = context?.currentFirmCurrencyCode;

      setState(() {
        _currencies = currencyResult;
        _countries = countryResult;
        
        if (widget.isEditing) {
          // --- DÜZELTME BURADA ---
          final price = widget.existingPrice!;
          _selectedCurrency = _tryFirstWhere(_currencies, (c) => c.id == price.currencyId);
          
          _selectedCountries = _countries.where((country) {
            return price.countryList.any((pc) => pc.countryId == country.id);
          }).toList();
        } else {
          // --- DÜZELTME BURADA ---
          _selectedCurrency = _tryFirstWhere(_currencies, (c) => c.code == defaultCurrencyCode);
          // Eğer varsayılan bulunamazsa, listedeki ilkini al
          if (_selectedCurrency == null && _currencies.isNotEmpty) {
            _selectedCurrency = _currencies.first;
          }
        }
        
        _isLookupsLoading = false;
      });
    } catch (e) {
      if(mounted) _showError('Form verileri yüklenemedi: $e');
      setState(() { _isLookupsLoading = false; });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() => _selectedStartDate = picked);
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_selectedCurrency == null) {
      _showError('Lütfen bir para birimi seçin.');
      return;
    }
    if (_selectedScopeType != ReferencePriceScopeType.AllCountries && _selectedCountries.isEmpty) {
      _showError('Lütfen "Sadece Listedekiler" veya "Listedekiler Hariç" seçimi için en az bir ülke seçin.');
      return;
    }

    setState(() { _isSaving = true; });

    try {
      bool success = false;
      final countryIdList = _selectedCountries.map((c) => c.id).toList();

      if (widget.isEditing) {
        final dto = UpdateReferencePriceDto(
          price: double.parse(_priceController.text),
          currencyId: _selectedCurrency!.id,
          priceUnitType: _selectedUnitType,
          startDate: _selectedStartDate,
          scopeType: _selectedScopeType,
          countryIds: countryIdList,
        );
        success = await _hsCodeApi.updateReferencePrice(widget.existingPrice!.id, dto);
      } else {
        final dto = CreateReferencePriceDto(
          hsCodeId: widget.hsCodeId,
          price: double.parse(_priceController.text),
          currencyId: _selectedCurrency!.id,
          priceUnitType: _selectedUnitType,
          startDate: _selectedStartDate,
          scopeType: _selectedScopeType,
          countryIds: countryIdList,
        );
        success = await _hsCodeApi.createReferencePrice(dto);
      }

      if (success && mounted) {
        _showSuccess(widget.isEditing ? 'Başarıyla güncellendi!' : 'Başarıyla eklendi!');
        Navigator.pop(context, true); // true = Listeyi yenile
      }
    } catch (e) {
      _showError('Hata: $e');
    } finally {
      if(mounted) setState(() { _isSaving = false; });
    }
  }
  
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Fiyatı Düzenle' : 'Yeni Fiyat Ekle')),
      body: _isLookupsLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Fiyat', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Gerekli';
                      if (double.tryParse(v) == null) return 'Geçersiz sayı';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownSearch<BaseCardViewModel>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: _currencies, 
                    itemAsString: (item) => item.description,
                    selectedItem: _selectedCurrency,
                    onChanged: (val) => setState(() => _selectedCurrency = val),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(labelText: 'Para Birimi', border: OutlineInputBorder()),
                    ),
                    validator: (v) => v == null ? 'Gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PriceUnitType>(
                    initialValue: _selectedUnitType,
                    decoration: const InputDecoration(labelText: 'Fiyat Birimi', border: OutlineInputBorder()),
                    items: PriceUnitType.values.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.text));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedUnitType = v!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(text: DateFormat('dd.MM.yyyy').format(_selectedStartDate)),
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Başlangıç Tarihi', border: OutlineInputBorder()),
                    onTap: () => _selectStartDate(context),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ReferencePriceScopeType>(
                    initialValue: _selectedScopeType,
                    decoration: const InputDecoration(labelText: 'Kapsam', border: OutlineInputBorder()),
                    items: ReferencePriceScopeType.values.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.text));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedScopeType = v!),
                  ),
                  
                  if (_selectedScopeType != ReferencePriceScopeType.AllCountries)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: DropdownSearch<BaseCardViewModel>.multiSelection(
                        popupProps: PopupPropsMultiSelection.menu(
                          showSearchBox: true,
                          searchFieldProps: const TextFieldProps(decoration: InputDecoration(labelText: 'Ülke Ara...')),
                        ),
                        items: _countries, 
                        itemAsString: (item) => item.description,
                        selectedItems: _selectedCountries,
                        onChanged: (val) => setState(() => _selectedCountries = val),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(labelText: 'Ülkeler (Beyaz/Kara Liste)', border: OutlineInputBorder()),
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 24),
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onSave,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                            child: const Text('KAYDET'),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}