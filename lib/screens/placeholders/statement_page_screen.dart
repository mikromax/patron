import 'dart:convert';
import "dart:io";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/account_transaction_statement_dto.dart';
import '../../models/nakit_varliklar_model.dart';
import '../../models/statement_detail_model.dart';
import '../../services/api_service.dart';
import 'document_detail_screen.dart';
import 'package:excel/excel.dart' hide Border; // Excel için gerekli
import 'package:path_provider/path_provider.dart'; // Excel için gerekli
import 'package:share_plus/share_plus.dart'; // Excel için gerekli
// Bu sınıflar ve enum'lar doğru, dokunmuyoruz
class LookupItem {
  final int value;
  final String text;
  LookupItem(this.value, this.text);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LookupItem &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
enum ApiCallState { idle, loading, success, error }


class StatementPageScreen extends StatefulWidget {
  final Detail detail;
  final LookupItem? preselectedGroup;

  const StatementPageScreen({super.key, required this.detail, this.preselectedGroup});

  @override
  State<StatementPageScreen> createState() => _StatementPageScreenState();
}

class _StatementPageScreenState extends State<StatementPageScreen> {
  // State değişkenleri doğru, dokunmuyoruz
  bool _isPanelExpanded = true;
  late DateTime _startDate;
  late DateTime _endDate;
  LookupItem? _selectedGroup;
  final List<LookupItem> _groupOptions = [
    LookupItem(1, 'Mevduat'),
  ];
  final ApiService _apiService = ApiService();
  ApiCallState _apiCallState = ApiCallState.idle;
  String _errorMessage = '';
  List<StatementDetailModel>? _statementData;

  //initState ve _fetchStatement fonksiyonları doğru, dokunmuyoruz
  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 7));
     // Eğer dışarıdan bir grup geldiyse, onu kullan ve listeye ekle.
    if (widget.preselectedGroup != null) {
      _selectedGroup = widget.preselectedGroup;
      // Listede zaten yoksa ekle
      if (!_groupOptions.any((item) => item.value == widget.preselectedGroup!.value)) {
        _groupOptions.add(widget.preselectedGroup!);
      }
    } else {
      _selectedGroup = _groupOptions.first;
    }
  }
  Future<void> _fetchStatement() async {
    if (_selectedGroup == null) return;
    setState(() {
      _apiCallState = ApiCallState.loading;
      _isPanelExpanded = false;
    });
    final dto = AccountTransactionStatementDto(
      code: widget.detail.code,
      startDate: _startDate,
      endDate: _endDate,
      group: _selectedGroup!.value,
    );
    try {
      final data = await _apiService.getAccountStatement(dto);
      setState(() {
        _statementData = data;
        _apiCallState = ApiCallState.success;
        if (data.isEmpty) {
          _isPanelExpanded = true;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _apiCallState = ApiCallState.error;
        _isPanelExpanded = true;
      });
    }
  }

  // Geri kalan tüm UI kodları (build, _build...Panel, _build...Picker) doğru
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.detail.definition} - Föy'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          _buildCollapsiblePanel(),
          Expanded(
            child: _buildResultArea(),
          ),
        ],
      ),
    );
  }
  Widget _buildCollapsiblePanel() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SizeTransition(sizeFactor: animation, child: child);
      },
      child: _isPanelExpanded
          ? _buildExpandedPanel()
          : _buildCollapsedPanelHeader(),
    );
  }
  Widget _buildCollapsedPanelHeader() {
    return InkWell(
      onTap: () => setState(() => _isPanelExpanded = true),
      child: Container(
        key: const ValueKey('collapsed'),
        padding: const EdgeInsets.all(12),
        color: Colors.grey[200],
        child: const Row(
          children: [
            Text('Filtreleri Göster', style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
  Widget _buildExpandedPanel() {
    return Container(
      key: const ValueKey('expanded'),
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildDatePicker('Başlangıç Tarihi', _startDate, (date) => setState(() => _startDate = date))),
              const SizedBox(width: 16),
              Expanded(child: _buildDatePicker('Bitiş Tarihi', _endDate, (date) => setState(() => _endDate = date))),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<LookupItem>(
            value: _selectedGroup,
            decoration: const InputDecoration(labelText: 'Grup', border: OutlineInputBorder()),
            items: _groupOptions.map((item) {
              return DropdownMenuItem<LookupItem>(
                value: item,
                child: Text(item.text),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedGroup = value),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _fetchStatement,
              child: const Text('Devam'),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onDateSelected) {
    final DateFormat formatter = DateFormat('dd.MM.yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2101));
            if (picked != null && picked != date) onDateSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatter.format(date)),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }


  // --- DEĞİŞİKLİK BURADA: switch...case bloğu düzeltildi ---
  Widget _buildResultArea() {
    switch (_apiCallState) {
      case ApiCallState.idle:
        return const Center(child: Text('Lütfen yukarıdan filtreleri seçip "Devam" butonuna basın.'));
      // YAZIM HATASI DÜZELTİLDİ: Artık 'loading' durumunu doğru tanıyor.
      case ApiCallState.loading:
        return const Center(child: CircularProgressIndicator());
      case ApiCallState.error:
        // Hata durumunda sonuç alanı boş kalacak, çünkü panel zaten açıldı
        // ve kullanıcı yeni bir deneme yapabilir.
        return const Center(child: Text(''));
      case ApiCallState.success:
        if (_statementData == null || _statementData!.isEmpty) {
          return const Center(child: Text('Seçilen kriterlere uygun veri bulunamadı.'));
        }
        return Column(
        children: [
          
          // 2. Butonun Kendisi ve Konumlandırması:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Align(
              // Align: İçindeki widget'ı hizalamamızı sağlar.
              alignment: Alignment.centerRight, // Butonu sağa yaslar.
              child: ElevatedButton.icon(
                // A. EYLEM: Butona basıldığında hangi fonksiyonun çalışacağını belirtir.
                onPressed: _exportStatementToExcel, 
                
                // B. GÖRSEL: Butonun ikonu ve rengi.
                icon: const Icon(Icons.description), 
                
                // C. GÖRSEL: Butonun üzerindeki yazı.
                label: const Text("Excel'e Aktar"), 

                // D. GÖRSEL: Butonun stilini (rengini vb.) belirler.
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D6F42), // Excel yeşili
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),

          // 3. Föy Listesi:
          // Expanded: "Geriye kalan tüm dikey alanı bu liste ile doldur" demektir.
          // Bu, butonun kendi yerini almasını ve listenin de taşma yapmadan
          // kalan tüm alanı kullanmasını sağlar.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _statementData!.length,
              itemBuilder: (context, index) {
                return _buildStatementCard(_statementData![index]);
              },
            ),
          ),
        ],
      );
    }
  }
Future<void> _exportStatementToExcel() async {
    if (_statementData == null || _statementData!.isEmpty) return;

    var excel = Excel.createExcel();
    Sheet sheetObject = excel[excel.getDefaultSheet()!];
   

    CellStyle headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('FFC5CAE9')
    );
    
    // Föy verisine uygun başlıklar
    List<String> headerList = ['Tarih', 'Seri', 'No', 'Tip', 'Borç/Alacak', 'Tutar (TL)', 'Orj. Tutar'];
    sheetObject.appendRow(headerList.map((col) => TextCellValue(col)).toList());
    
    for (var i = 0; i < headerList.length; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
    }

    // Föy verisini satırlara yazma
    final DateFormat formatter = DateFormat('dd.MM.yyyy');
    for (var line in _statementData!) {
      var row = [
        TextCellValue(formatter.format(line.transactionDate)),
        TextCellValue(line.documentSerial),
        IntCellValue(line.documentNumber), // Artık IntCellValue kullanıyoruz
        TextCellValue(line.documentType),
        TextCellValue(line.debitCredit),
        DoubleCellValue(line.amountTl),
        DoubleCellValue(line.amountOriginal),
      ];
      sheetObject.appendRow(row);
    }
    
    // Sütun genişliklerini ayarla
    

    final directory = await getTemporaryDirectory();
    final fileName = 'hesap_foyu_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final path = '${directory.path}/$fileName';
    
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      
      await Share.shareXFiles([XFile(file.path)], text: 'Hesap Föy Raporu');
    }
  }
  // Bu fonksiyon da doğru, dokunmuyoruz
  Widget _buildStatementCard(StatementDetailModel line) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final numberFormatter = NumberFormat("#,##0.00", "tr_TR");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Column(
              children: [
                Text(DateFormat('dd').format(line.transactionDate), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM', 'tr_TR').format(line.transactionDate).toUpperCase()),
                Text(DateFormat('yyyy').format(line.transactionDate), style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const VerticalDivider(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${line.documentSerial} ${line.documentNumber} - (${line.documentType})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        line.debitCredit,
                        style: TextStyle(color: (line.debitCredit == 'Borç') ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(currencyFormatter.format(line.amountTl), style: const TextStyle(fontWeight: FontWeight.bold)),
                          if(line.amountOriginal != line.amountTl)
                            Text(
                              '(${numberFormatter.format(line.amountOriginal)})', 
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => DocumentDetailScreen(statementLine: line),
                        ));
                      },
                      child: const Text('Evrak Detay'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}