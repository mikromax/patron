import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/Helpers/document_sequence_type.dart';
import '../../../models/CreditLimit/customer_limit_dto.dart'; // YENİ MODEL
import '../../../models/Helpers/base_card_view_model.dart'; // Arama için
import '../../../models/Helpers/paginated_search_query.dart';
import '../../../models/Helpers/search_type.dart';
import '../../../services/api/settings_api.dart';
import '../../Helpers/paginated_search_screen.dart'; // Arama için
import 'package:uuid/uuid.dart';
import '../../../models/CreditLimit/credit_limit_request_types.dart';
import '../../../models/CreditLimit/create_credit_limit_request_dto.dart';
import '../../Attachments/attachment_screen.dart';
import '../../../services/api/credit_limit_api.dart';
import '../../../services/api/finance_api.dart';
class CreditLimitRequestScreen extends StatefulWidget {
  const CreditLimitRequestScreen({super.key});

  @override
  State<CreditLimitRequestScreen> createState() => _CreditLimitRequestScreenState();
}

class _CreditLimitRequestScreenState extends State<CreditLimitRequestScreen> {
  final Uuid _uuid = const Uuid();
  final SettingsApi _apisettings = SettingsApi();
  final CreditLimitApi _apiService = CreditLimitApi();
  final FinanceApi _apiFinance = FinanceApi();
  final _formKey = GlobalKey<FormState>();
  final _docNumberController = TextEditingController();
  final _customerCodeController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _currentLimitController = TextEditingController();
  final _requestedLimitController = TextEditingController();
  final _validityDateController = TextEditingController();
  final _commentController = TextEditingController();
  
  bool _isLoading = true;
  bool _isLoadingLimit = false;
  bool _isSaving = false;
  String? _savedRequestId; // Talebin kaydedilip edilmediğini tutar (Guid)

  List<CustomerLimitDto> _currentLimitDetails = [];
  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 365));
  CreditLimitRequestTypes _selectedRequestType = CreditLimitRequestTypes.TemporaryAdditionalLimit; // Varsayılan

  final _currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  
  @override
  void initState() {
    super.initState();
    _loadNewDocument();
  }

  Future<void> _loadNewDocument() async {
    setState(() { 
      _isLoading = true; 
      _savedRequestId = null;
    });
    
    _formKey.currentState?.reset();
    _customerCodeController.clear();
    _customerNameController.clear();
    _currentLimitController.clear();
    _requestedLimitController.clear();
    _commentController.clear();
    _selectedRequestType = CreditLimitRequestTypes.TemporaryAdditionalLimit;
    _currentLimitDetails = [];

    _selectedExpiryDate = DateTime.now().add(const Duration(days: 365));
    _validityDateController.text = DateFormat('dd.MM.yyyy').format(_selectedExpiryDate);

    try {
      final docNumber = await _apisettings.getNextDocumentNumber(DocumentSequenceType.CreditLimitRequest);
      setState(() {
        _docNumberController.text = docNumber;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Yeni evrak numarası alınamadı: $e');
      setState(() { _isLoading = false; });
    }
  }
  
  // --- DOKÜMAN ARAMA BUTONU ARTIK İŞLEVSEL ---
  Future<void> _onDocumentSearch() async {
    final result = await Navigator.push<BaseCardViewModel>(
      context,
      MaterialPageRoute(
        builder: (context) => PaginatedSearchScreen(
          title: 'Kredi Talep Ara',
          searchType: SearchType.creditLimitRequest,
          onSearch: (PaginatedSearchQuery query) => _apiService.searchCreditLimitRequests(query),
        ),
      ),
    );

    if (result != null) {
      // Bir evrak seçildi, tüm detaylarını getir
      await _loadExistingRequest(result.code); // 'code' alanı DocumentNumber'ı tutar
    }
  }

  // --- YENİ FONKSİYON: MEVCUT EVRAĞI YÜKLE ---
  Future<void> _loadExistingRequest(String documentNumber) async {
    setState(() { _isLoading = true; }); // Tüm ekranı yükleme moduna al
    try {
      final details = await _apiService.getRequestByDocumentNumber(documentNumber);
      
      // Formu API'den gelen verilerle doldur
      setState(() {
        _savedRequestId = details.id; // Bu artık kayıtlı bir evrak
        _docNumberController.text = details.documentNumber;
        _customerCodeController.text = details.customerCode;
        _customerNameController.text = details.customerName; // Yeni alan
        _currentLimitController.text = _currencyFormatter.format(details.currentLimit);
        _requestedLimitController.text = details.requestedLimit.toString();
        _selectedExpiryDate = details.expiryDate;
        _validityDateController.text = DateFormat('dd.MM.yyyy').format(details.expiryDate);
        _commentController.text = details.explanation;
        _selectedRequestType = details.requestType;

        // Müşteri limit detaylarını da yükleyelim (opsiyonel ama tutarlı)
        _onCustomerSearch(loadLimitOnly: true);
        
        _isLoading = false;
      });
    } catch (e) {
      _showError('Evrak yüklenemedi: $e');
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _onCustomerSearch({bool loadLimitOnly = false}) async {
    BaseCardViewModel? result;
    if (!loadLimitOnly) {
      // 1. Arama ekranını aç
      result = await Navigator.push<BaseCardViewModel>(
        context,
        MaterialPageRoute(
          builder: (context) => PaginatedSearchScreen(
            title: 'Cari/Müşteri Ara',
            searchType: SearchType.customer,
            onSearch: (PaginatedSearchQuery query) => _apisettings.searchCustomers(query),
          ),
        ),
      );
      if (result == null) return; // Kullanıcı seçim yapmadı
    }

    setState(() {
      if (!loadLimitOnly) {
        _customerNameController.text = result!.description;
        _customerCodeController.text = result.code;
      }
      _isLoadingLimit = true;
      _currentLimitController.text = 'Yükleniyor...';
      _currentLimitDetails = [];
    });

    try {
      final limitDetails = await _apiFinance.getCustomerCurrentLimit(_customerCodeController.text);
      final double openCreditTotal = limitDetails
          .where((dto) => dto.descriptionName == "Açık Tanınan Kredi")
          .fold(0.0, (sum, item) => sum + item.totalAmount);
      
      setState(() {
        _currentLimitController.text = _currencyFormatter.format(openCreditTotal);
        _currentLimitDetails = limitDetails;
        _isLoadingLimit = false;
      });
    } catch (e) {
      setState(() { _currentLimitController.text = 'Hata!'; _isLoadingLimit = false; });
      _showError('Müşteri limiti alınamadı: $e');
    }
  }
  
  Future<void> _onSaveRequest() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() { _isSaving = true; });

    try {
      final String requestId = _savedRequestId ?? _uuid.v4();
      final dto = CreateCreditLimitRequestDto(
        id: requestId,
        documentNumber: _docNumberController.text,
        customerCode: _customerCodeController.text,
        currentLimit: double.tryParse(_currentLimitController.text.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll('.', '').replaceAll(',', '.')) ?? 0.0,
        requestedLimit: double.parse(_requestedLimitController.text),
        expiryDate: _selectedExpiryDate,
        explanation: _commentController.text,
        requestType: _selectedRequestType,
      );
      
      final returnedId = await _apiService.createCreditLimitRequest(dto);
      if (returnedId) {
            setState(() {
        _savedRequestId = requestId;
        _isSaving = false;
      });
      _showSuccess("Talep başarıyla kaydedildi/güncellendi.");
      }
      else {
        _showError("Hata Kayıt Başarısız.");
      }
    } catch (e) {
      _showError('Talep kaydedilemedi: $e');
      setState(() { _isSaving = false; });
    }
  }

 void _onAttachments() {
    // Bu buton sadece _savedRequestId null değilse aktiftir
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AttachmentScreen(
        entityName: "CreditLimitRequest", // API'nin beklediği Entity Adı
        entityId: _savedRequestId!, // Kayıtlı talebin Guid'i
      ))
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }
  
  void _showLimitDetailsModal() { /* ... (Bu fonksiyon değişmedi) ... */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kredi Limiti Talebi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _docNumberController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Evrak Numarası',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
              // --- DÜZELTME: ARTIK _onDocumentSearch'İ ÇAĞIRIYOR ---
              suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _onDocumentSearch),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerNameController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Müşteri',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () => _onCustomerSearch(loadLimitOnly: false)),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Müşteri seçmek zorunludur.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _currentLimitController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Açık Tanınan Kredi',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
              suffixIcon: _isLoadingLimit
                ? const Padding(padding: EdgeInsets.all(10.0), child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    icon: const Icon(Icons.list_alt),
                    tooltip: 'Tüm Limitleri Göster',
                    onPressed: _currentLimitDetails.isNotEmpty ? _showLimitDetailsModal : null,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<CreditLimitRequestTypes>(
            initialValue: _selectedRequestType,
            decoration: const InputDecoration(labelText: 'Talep Tipi', border: OutlineInputBorder()),
            items: CreditLimitRequestTypes.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.text));
            }).toList(),
            onChanged: (value) => setState(() => _selectedRequestType = value!),
            validator: (v) => v == null ? 'Bu alan zorunludur.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _requestedLimitController,
            decoration: const InputDecoration(labelText: 'İstenen Kredi Limiti', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Bu alan zorunludur.';
              final d = double.tryParse(v);
              if (d == null || d <= 0) return 'Lütfen 0\'dan büyük bir değer girin.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _validityDateController,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Geçerlilik Tarihi', border: OutlineInputBorder()),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedExpiryDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                setState(() => _selectedExpiryDate = picked);
                _validityDateController.text = DateFormat('dd.MM.yyyy').format(picked);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
            maxLines: 3,
            validator: (v) => (v == null || v.isEmpty) ? 'Açıklama zorunludur.' : null,
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Yeni'),
                onPressed: _isSaving ? null : _loadNewDocument,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Dosya Ekleri'),
                onPressed: _savedRequestId == null || _isSaving ? null : _onAttachments,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
                onPressed: _isSaving ? null : _onSaveRequest,
              ),
            ],
          ),
        ],
      ),
    );
  }
}