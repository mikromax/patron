import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patron/services/api/orders_api.dart';
import '../../models/Approvals/approve_document_dto.dart'; // YENİ MODELİ IMPORT ET
import '../../models/Helpers/field_hint_dto.dart';
import '../../models/Helpers/paginated_search_query.dart';
import '../../models/Approvals/paginated_pending_approval_headers_dto.dart';
import '../../models/Approvals/pending_approval_header_dto.dart';
import '../../services/api/approvals_api.dart';
import '../../models/Approvals/approval_document_type.dart';
import '../../models/Approvals/approval_layout_hints_dto.dart';
import '../../models/Approvals/cancel_document_dto.dart';
import '../../models/Helpers/base_card_view_model.dart';
import 'document_lines_screen.dart'; 
class DocumentApprovalScreen extends StatefulWidget {
  final String title;
  final ApprovalDocumentType documentType;

  const DocumentApprovalScreen({
    super.key, 
    required this.title,
    required this.documentType,
  });

  @override
  State<DocumentApprovalScreen> createState() => _DocumentApprovalScreenState();
}

class _DocumentApprovalScreenState extends State<DocumentApprovalScreen> {
  final ApprovalsApi _apiService = ApprovalsApi();
  final OrdersApi _apiorders = OrdersApi();
  PaginatedPendingApprovalHeadersDto? _result;
  bool _isLoading = true;
  String _errorMessage = '';
  final PaginatedSearchQuery _currentQuery = PaginatedSearchQuery(); 

  // --- YENİ STATE DEĞİŞKENİ ---
  // Hangi kartın onaylanmakta olduğunu takip etmek için,
  // sadece o kartta bir yükleme animasyonu gösterelim.
  String? _approvingDocId;
  String? _cancellingDocId;
  final _currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  final _dateFormatter = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() { _isLoading = true; });
    }
    try {
      final result = await _apiService.getPendingApprovals(widget.documentType, _currentQuery);
      setState(() {
        _result = result;
        _currentQuery.pageNumber = result.paginatedData.currentPage;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _nextPage() {
    if (_result != null && _currentQuery.pageNumber < _result!.paginatedData.totalPages) {
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
  Future<void> _showCancelDialog(PendingApprovalHeaderDto header) async {
    final dialogFormKey = GlobalKey<FormState>();
    final commentController = TextEditingController();
    List<BaseCardViewModel>? cancelReasons;
    BaseCardViewModel? selectedReason;
    bool isDialogLoading = true;
    bool isSubmitting = false;

    // Diyalogu açmadan önce iptal nedenlerini yükle
    try {
      cancelReasons = await _apiorders.getOrderCancelReasons();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
      return; // Nedenler yüklenemezse diyalogu açma
    }

    // Nedenler yüklendikten sonra diyalogu göster
    if (mounted) {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          // Diyalogun kendi state'ini yönetmesi için StatefulBuilder
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Evrağı Kapat'),
                content: Form(
                  key: dialogFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // İptal Nedeni Lookup
                        DropdownButtonFormField<BaseCardViewModel>(
                          initialValue: selectedReason,
                          decoration: const InputDecoration(labelText: 'Kapatma Nedeni', border: OutlineInputBorder()),
                          items: cancelReasons?.map((reason) {
                            return DropdownMenuItem<BaseCardViewModel>(
                              value: reason,
                              child: Text(reason.description),
                            );
                          }).toList(),
                          onChanged: (value) => setDialogState(() => selectedReason = value),
                          validator: (value) => value == null ? 'Lütfen bir neden seçin.' : null,
                        ),
                        const SizedBox(height: 16),
                        // Yorum Alanı
                        TextFormField(
                          controller: commentController,
                          decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
                          maxLines: 3,
                          validator: (value) => (value == null || value.isEmpty) ? 'Açıklama zorunludur.' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (isSubmitting) const CircularProgressIndicator(),
                  TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                    child: const Text('İptal'),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : () async {
                      if (dialogFormKey.currentState!.validate()) {
                        setDialogState(() => isSubmitting = true);
                        await _submitCancellation(header, selectedReason!, commentController.text);
                        if (mounted) Navigator.pop(dialogContext); // Başarılı veya başarısız, diyalogu kapat
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Evrağı Kapat'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  // --- YENİ FONKSİYON: EVRAK KAPATMA API ÇAĞRISI ---
  Future<void> _submitCancellation(PendingApprovalHeaderDto header, BaseCardViewModel reason, String comment) async {
    setState(() {
      _cancellingDocId = header.documentNumber; // Bu kart için yüklemeyi başlat
    });

    try {
      final dto = CancelDocumentDto(
        documentType: widget.documentType,
        documentNumber: header.documentNumber,
        cancelReason: reason.code, // Lookup'tan seçilen nedenin KODU
        comment: comment,
      );

      await _apiService.cancelDocument(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evrak başarıyla kapatıldı!'), backgroundColor: Colors.green),
        );
      }
      _fetchData(showLoading: false); // Listeyi yenile

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cancellingDocId = null; // Yüklemeyi bitir
        });
      }
    }
  }
  // --- YENİ FONKSİYON: EVRAK ONAYLAMA MANTIĞI ---
  Future<void> _approveDocument(PendingApprovalHeaderDto header) async {
    // Zaten bir işlem varsa tekrar basılmasını engelle
    if (_approvingDocId != null) return;

    setState(() {
      _approvingDocId = header.documentNumber; // Bu kart için yüklemeyi başlat
    });

    try {
      final dto = ApproveDocumentDto(
        documentType: widget.documentType,
        documentNumber: header.documentNumber,
      );

      await _apiService.approveDocument(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evrak başarıyla onaylandı!'), backgroundColor: Colors.green),
        );
      }
      
      // Onay başarılı! Listeyi yenile (ve animasyonu gizle)
      _fetchData(showLoading: false); // Sayfanın tamamını yükleme moduna almadan listeyi yenile

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _approvingDocId = null; // Yüklemeyi bitir
        });
      }
    }
  }

  void _showDetailModal(BuildContext context, PendingApprovalHeaderDto header, List<FieldHintDto> detailFields) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Evrak Detayları", style: Theme.of(context).textTheme.titleLarge),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: detailFields.length,
                  itemBuilder: (context, index) {
                    final hint = detailFields[index];
                    final value = header.getField(hint.fieldName);
                    final displayValue = _formatValue(value);
                    return ListTile(
                      title: Text(hint.displayName),
                      trailing: Text(displayValue, style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
  
  String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) return _dateFormatter.format(value);
    if (value is double) return _currencyFormatter.format(value);
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage.isNotEmpty)
            Expanded(child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))))
          else if (_result == null || _result!.paginatedData.data.isEmpty)
            const Expanded(child: Center(child: Text('Onay bekleyen evrak bulunamadı.')))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _result!.paginatedData.data.length,
                itemBuilder: (context, index) {
                  final header = _result!.paginatedData.data[index];
                  return _buildApprovalCard(header, _result!.layoutHints);
                },
              ),
            ),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(PendingApprovalHeaderDto header, ApprovalLayoutHintsDto layoutHints) {
    List<Widget> summaryWidgets = layoutHints.headerSummaryFields.map((hint) {
      var value = header.getField(hint.fieldName);
      String displayValue = _formatValue(value);
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(hint.displayName, style: const TextStyle(color: Colors.grey)),
            Text(displayValue, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...summaryWidgets,
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
               // Bu kart şu an onaylanıyorsa, kum saati göster
                if (_approvingDocId == header.documentNumber)
                  const Padding(
                    padding: EdgeInsets.all(12.0), // IconButton'ın boyutuyla eşleşsin
                    child: SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    ),
                  )
                else
                  // Değilse, butonu göster
                  IconButton(
                    icon: const Icon(Icons.check), 
                    color: Colors.green, 
                    tooltip: 'Onayla', 
                    onPressed: () => _approveDocument(header),
                  ),

                IconButton(
                  icon: const Icon(Icons.list_alt), 
                  color: Colors.blue, 
                  tooltip: 'Satırlar', 
                  onPressed: (_approvingDocId != null || _cancellingDocId != null) 
                    ? null 
                    : () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => DocumentLinesScreen(
                          documentNumber: header.documentNumber,
                          documentType: widget.documentType,
                        ),
                      ));
                    }
                ),
                // Kapat Butonu (veya yükleniyor animasyonu)
                if (_cancellingDocId == header.documentNumber)
                  _buildLoadingIndicator()
                else
                  IconButton(
                    icon: const Icon(Icons.close), 
                    color: Colors.red, 
                    tooltip: 'Kapat', 
                    onPressed: (_approvingDocId != null || _cancellingDocId != null) ? null : () => _showCancelDialog(header),
                  ),
                IconButton(
                  icon: const Icon(Icons.more_horiz), 
                  color: Colors.grey, 
                  tooltip: 'Detay', 
                  onPressed: () => _showDetailModal(context, header, layoutHints.headerDetailFields),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
   Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(12.0),
      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildPaginationControls() {
    if (_result == null || _result!.paginatedData.totalCount == 0) return const SizedBox.shrink();
    final data = _result!.paginatedData;
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.first_page), onPressed: _currentQuery.pageNumber > 1 ? () { setState(() => _currentQuery.pageNumber = 1); _fetchData(); } : null),
          IconButton(icon: const Icon(Icons.navigate_before), onPressed: _currentQuery.pageNumber > 1 ? _prevPage : null),
          Text('Sayfa ${data.currentPage} / ${data.totalPages} (${data.totalCount} kayıt)'),
          IconButton(icon: const Icon(Icons.navigate_next), onPressed: _currentQuery.pageNumber < data.totalPages ? _nextPage : null),
          IconButton(icon: const Icon(Icons.last_page), onPressed: _currentQuery.pageNumber < data.totalPages ? () { setState(() => _currentQuery.pageNumber = data.totalPages); _fetchData(); } : null),
        ],
      ),
    );
  }
}