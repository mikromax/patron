// lib/screens/document_lines_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/Approvals/approval_document_type.dart';
import '../../models/Approvals/approval_lines_response_dto.dart';
import '../../models/Helpers/field_hint_dto.dart';
import '../../models/Approvals/pending_approval_line_dto.dart';
import '../../models/orders_by_customer_vm.dart';
import '../approve_order_screen.dart';
import '../cancel_order_screen.dart';
import '../../models/Approvals/approval_line_layout_hints_dto.dart';
import '../../services/api/approvals_api.dart';
class DocumentLinesScreen extends StatefulWidget {
  final String documentNumber;
  final ApprovalDocumentType documentType;

  const DocumentLinesScreen({
    super.key, 
    required this.documentNumber,
    required this.documentType,
  });

  @override
  State<DocumentLinesScreen> createState() => _DocumentLinesScreenState();
}

class _DocumentLinesScreenState extends State<DocumentLinesScreen> {
  final ApprovalsApi _apiService = ApprovalsApi();
  late Future<ApprovalLinesResponseDto> _linesFuture;
  
  // Formatlayıcılar
  final _currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  final _dateFormatter = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _linesFuture = _fetchData();
  }

  Future<ApprovalLinesResponseDto> _fetchData() {
    return _apiService.getApprovalLines(widget.documentType, widget.documentNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Evrak Satırları (${widget.documentNumber})')),
      body: FutureBuilder<ApprovalLinesResponseDto>(
        future: _linesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.lines.isEmpty) {
            return const Center(child: Text('Evrak satırı bulunamadı.'));
          }

          final response = snapshot.data!;
          final lines = response.lines;
          final layoutHints = response.layoutHints;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: lines.length,
            itemBuilder: (context, index) {
              return _buildLineCard(lines[index], layoutHints);
            },
          );
        },
      ),
    );
  }

  Widget _buildLineCard(PendingApprovalLineDto line, ApprovalLineLayoutHintsDto layoutHints) {
    // API'den gelen talimatlara göre dinamik özet alanlarını oluştur
    List<Widget> summaryWidgets = layoutHints.lineSummaryFields.map((hint) {
      var value = line.getField(hint.fieldName);
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

    // Özel alanlar butonu için kontrol
    final bool hasUserFields = line.userDefinedFields.isNotEmpty;

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
                IconButton(icon: const Icon(Icons.check), color: Colors.green, tooltip: 'Onayla', onPressed: () => _onApprove(line)),
                IconButton(icon: const Icon(Icons.list_alt), color: Colors.blue, tooltip: 'Detay', onPressed: () => _showDetailModal(line, layoutHints.lineDetailFields)),
                IconButton(icon: const Icon(Icons.close), color: Colors.red, tooltip: 'Kapat', onPressed: () => _onCancel(line)),
                IconButton(icon: const Icon(Icons.note_alt_outlined), color: Colors.orange, tooltip: 'Özel Alanlar', onPressed: hasUserFields ? () => _showUserFieldsModal(line.userDefinedFields) : null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) return _dateFormatter.format(value);
    if (value is double) return _currencyFormatter.format(value);
    return value.toString();
  }

  // --- YENİDEN KULLANIM MANTIĞI ---
  
  // OrdersByCustomerVM'i taklit eden bir nesne oluştururuz
  OrdersByCustomerVM _createDummyOrder(PendingApprovalLineDto line) {
    return OrdersByCustomerVM(
      orderId: line.lineId, // Satırın ID'sini Sipariş ID'si olarak kullanıyoruz
      quantity: line.quantity1, // Satır miktarını kullanıyoruz
      // Diğer alanları, onay/iptal ekranlarının ihtiyaç duyduğu
      // minimum verilerle dolduruyoruz.
      orderType: widget.documentType.value,
      orderDate: line.deliveryDate,
      code: line.itemCode,
      name: line.itemName,
      unit: line.itemUnit,
      amount: line.amount,
      currency: line.currency,
      isApproved: false, // Bu ekranda zaten onaylanmamışları görüyoruz
    );
  }
  
  void _onApprove(PendingApprovalLineDto line) {
    // Daha önce yazdığımız ApproveOrderScreen'i yeniden kullanıyoruz
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ApproveOrderScreen(order: _createDummyOrder(line)),
    )).then((isSuccess) {
      if (isSuccess == true) _fetchData(); // Başarılı olursa listeyi yenile
    });
  }

  void _onCancel(PendingApprovalLineDto line) {
    // Daha önce yazdığımız CancelOrderScreen'i yeniden kullanıyoruz
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => CancelOrderScreen(order: _createDummyOrder(line)),
    )).then((isSuccess) {
      if (isSuccess == true) _fetchData(); // Başarılı olursa listeyi yenile
    });
  }

  // Header'daki ile aynı Detay gösterme paneli
  void _showDetailModal(PendingApprovalLineDto line, List<FieldHintDto> detailFields) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: const EdgeInsets.all(16.0), child: Text("Satır Detayları", style: Theme.of(context).textTheme.titleLarge)),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: detailFields.length,
                  itemBuilder: (context, index) {
                    final hint = detailFields[index];
                    final value = line.getField(hint.fieldName);
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

  // Özel Alanları gösteren yeni panel
  void _showUserFieldsModal(Map<String, dynamic> userFields) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final entries = userFields.entries.toList();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(16.0), child: Text("Kullanıcı Tanımlı Alanlar", style: Theme.of(context).textTheme.titleLarge)),
            const Divider(height: 1),
            LimitedBox(
              maxHeight: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    title: Text(entry.key), // Alanın Adı
                    trailing: Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)), // Alanın Değeri
                  );
                },
              ),
            ),
          ],
        );
      }
    );
  }
}