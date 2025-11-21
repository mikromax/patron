import 'package:path/path.dart' as path;
import 'dart:io'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart'; // Sayı formatlama için eklendi
import '../../models/Helpers/base_card_view_model.dart';
import '../../models/Helpers/paginated_search_query.dart';
import '../../models/Helpers/search_type.dart';
import '../../models/ForeignTrade/import_expense_distribution_dto.dart';
import '../../models/ForeignTrade/import_expense_dto.dart';
import '../../models/ForeignTrade/import_file_details_dto.dart';
import '../../models/ForeignTrade/import_item_dto.dart';
import '../../services/api/ForeignTrade/foreign_trade_api.dart';
import '../helpers/paginated_search_screen.dart';
import '../placeholders/generic_placeholder_screen.dart';

class ImportDocumentScreen extends StatefulWidget {
  const ImportDocumentScreen({super.key});

  @override
  State<ImportDocumentScreen> createState() => _ImportDocumentScreenState();
}

class _ImportDocumentScreenState extends State<ImportDocumentScreen> {
  final ForeignTradeApi _api = ForeignTradeApi();
  
  bool _isLoadingDetails = false;
  ImportFileDetailsDto? _details;
  
  final _fileSearchController = TextEditingController();
  String? _selectedFileId;

  ImportExpenseDSource? _expenseDataSource;
  ImportItemDSource? _itemDataSource;
  ImportDistDSource? _distDataSource;

  final NumberFormat _n2Formatter = NumberFormat("#,##0.00", "tr_TR");

  // Arama ve Yükleme fonksiyonları (Değişiklik yok)
  Future<void> _onSearchFile() async {
    final result = await Navigator.push<BaseCardViewModel>(
      context,
      MaterialPageRoute(
        builder: (context) => PaginatedSearchScreen(
          title: 'İthalat Dosyası Ara',
          searchType: SearchType.other,
          onSearch: (PaginatedSearchQuery query) => _api.searchImportFiles(query),
        ),
      ),
    );

    if (result != null) {
      _fileSearchController.text = result.description;
      _selectedFileId = result.id;
      _loadDetails(result.id);
    }
  }
 // --- YENİ FONKSİYONLAR: EXCEL'E AKTARMA ---
  
  // 1. DAĞITIM GRİDİ İÇİN
  Future<void> _exportDistGrid() async {
    if (_details == null) return;
    var excel = Excel.createExcel();
    Sheet sheet = excel[excel.getDefaultSheet()!];

    // Başlıklar
    List<String> headerList = ['Stok Kodu', 'Stok Adı', 'Masraf Grubu', 'Dağıtılan Tutar (TL)', 'KDV (TL)', 'Miktar', 'Ağırlık', 'Hacim'];
    sheet.appendRow(headerList.map((col) => TextCellValue(col)).toList());

    // Veri
    for (var e in _details!.importExpenseDistributions) {
      sheet.appendRow([
        TextCellValue(e.itemCode),
        TextCellValue(e.itemName),
        IntCellValue(e.expenseGroup),
        DoubleCellValue(e.distributedAmount),
        DoubleCellValue(e.calculatedVatAmount),
        DoubleCellValue(e.quantity),
        DoubleCellValue(e.weight),
        DoubleCellValue(e.volume),
      ]);
    }
    _saveAndShareExcel(excel, 'dagitim_raporu');
  }

  // 2. MASRAF GRİDİ İÇİN
  Future<void> _exportExpenseGrid() async {
    if (_details == null) return;
    var excel = Excel.createExcel();
    Sheet sheet = excel[excel.getDefaultSheet()!];

    List<String> headerList = ['Masraf Adı', 'Tutar', 'Döviz', 'Kur', 'Dağıtılan', 'Kalan'];
    sheet.appendRow(headerList.map((col) => TextCellValue(col)).toList());

    for (var e in _details!.expenses) {
      sheet.appendRow([
        TextCellValue(e.expenseName),
        DoubleCellValue(e.amount),
        TextCellValue(e.currencyName),
        DoubleCellValue(e.exchangeRate),
        DoubleCellValue(e.distributedAmount),
        DoubleCellValue(e.remainingAmount),
      ]);
    }
    _saveAndShareExcel(excel, 'masraf_raporu');
  }

  // 3. STOK GRİDİ İÇİN
  Future<void> _exportItemGrid() async {
    if (_details == null) return;
    var excel = Excel.createExcel();
    Sheet sheet = excel[excel.getDefaultSheet()!];

    List<String> headerList = ['Stok Kodu', 'Stok Adı', 'Miktar', 'Birim', 'Mal Bedeli', 'Döviz', 'GTİP Kodu'];
    sheet.appendRow(headerList.map((col) => TextCellValue(col)).toList());

    for (var e in _details!.items) {
      sheet.appendRow([
        TextCellValue(e.itemCode),
        TextCellValue(e.itemName),
        DoubleCellValue(e.quantity),
        TextCellValue(e.unit),
        DoubleCellValue(e.itemAmount),
        TextCellValue(e.currencyName),
        TextCellValue(e.hsCode?.code ?? 'N/A'),
      ]);
    }
    _saveAndShareExcel(excel, 'stok_raporu');
  }

Future<void> _saveAndShareExcel(Excel excel, String fileNamePrefix) async {
    try {
      String directoryPath;

      // Platformu kontrol et
      if (Platform.isWindows) {
        // Windows ise: Programın çalıştığı dizini al
        // 'Platform.resolvedExecutable' -> D:\Flutter\patron\patron\build\windows\runner\Debug\patron.exe
        // 'path.dirname(...)' -> D:\Flutter\patron\patron\build\windows\runner\Debug
        directoryPath = path.dirname(Platform.resolvedExecutable);
      } else {
        // Mobil ise (Android/iOS): Geçici dizini al
        final directory = await getTemporaryDirectory();
        directoryPath = directory.path;
      }

      final pathString = '$directoryPath/${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(pathString)..writeAsBytesSync(fileBytes);
        
        if (!mounted) return;

        // Hem Windows hem de Mobil, Share.shareXFiles'ı destekler
        // Mobilde "Paylaş" menüsünü açar.
        // Windows'ta "Windows Paylaşım" diyaloğunu açar.
        await Share.shareXFiles([XFile(file.path)], text: 'İthalat Raporu');
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excel oluşturulamadı: $e'), backgroundColor: Colors.red));
    }
  }
  Future<void> _loadDetails(String id) async {
    setState(() { _isLoadingDetails = true; _details = null; });
    try {
      final details = await _api.getImportFileDetails(id);
      
      _distDataSource = ImportDistDSource(items: details.importExpenseDistributions, formatter: _n2Formatter);
      _expenseDataSource = ImportExpenseDSource(items: details.expenses, formatter: _n2Formatter);
      _itemDataSource = ImportItemDSource(items: details.items, formatter: _n2Formatter);

      setState(() {
        _details = details;
        _isLoadingDetails = false;
      });
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      setState(() { _isLoadingDetails = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('İthalat Masraf Dağıtımı'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Kaydet',
              onPressed: _details == null ? null : () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericPlaceholderScreen(pageTitle: 'Kaydet')));
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Dışa Aktar',
              enabled: _details != null, // Sadece veri varken aktif
              onSelected: (value) {
                if (value == 'dist') _exportDistGrid();
                if (value == 'expense') _exportExpenseGrid();
                if (value == 'item') _exportItemGrid();
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'dist',
                  child: Text('Dağıtımları Excel\'e Aktar'),
                ),
                const PopupMenuItem<String>(
                  value: 'expense',
                  child: Text('Masrafları Excel\'e Aktar'),
                ),
                const PopupMenuItem<String>(
                  value: 'item',
                  child: Text('Stokları Excel\'e Aktar'),
                ),
              ],
            ),

          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dağıtılmış Masraflar'),
              Tab(text: 'Masraf Listesi'),
              Tab(text: 'Stok Listesi'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _fileSearchController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'İthalat Dosyası',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _onSearchFile,
                  ),
                ),
              ),
            ),
            
            if (_isLoadingDetails)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_details == null)
              const Expanded(child: Center(child: Text('Lütfen bir ithalat dosyası seçin.')))
            else
              Expanded(
                child: TabBarView(
                  children: [
                    _buildDistributionGrid(_distDataSource!),
                    _buildExpenseGrid(_expenseDataSource!),
                    _buildItemsGrid(_itemDataSource!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- DATAGRID OLUŞTURUCULAR (GÜNCELLENDİ) ---
  // Sizin bulduğunuz 'tableSummaryRows' örneğine göre güncellendi.

  Widget _buildDistributionGrid(ImportDistDSource dataSource) {
    return SfDataGrid(
      source: dataSource,
      // allowFiltering: true, // İsteğiniz üzerine kaldırıldı
      
      // --- DÜZELTME BURADA: Dip Toplam ---
      tableSummaryRows: [
        GridTableSummaryRow(
          position: GridTableSummaryRowPosition.bottom,
          columns: [
            // Her kolon için bir Summary tanımı
            GridSummaryColumn(name: 'itemCode', columnName: 'itemCode', summaryType: GridSummaryType.count),
            GridSummaryColumn(name: 'distributedAmount', columnName: 'distributedAmount', summaryType: GridSummaryType.sum),
            GridSummaryColumn(name: 'calculatedVatAmount', columnName: 'calculatedVatAmount', summaryType: GridSummaryType.sum),
          ],
        ),
      ],
      // ------------------------------------
      
      columns: [
        GridColumn(columnName: 'itemCode', label: const Text('Stok Kodu')),
        GridColumn(columnName: 'itemName', label: const Text('Stok Adı')),
        GridColumn(columnName: 'expenseGroup', label: const Text('Masraf Grubu')),
        GridColumn(columnName: 'distributedAmount', label: const Text('Dağıtılan Tutar (TL)')),
        GridColumn(columnName: 'calculatedVatAmount', label: const Text('KDV (TL)')),
        
        
        GridColumn(columnName: 'quantity', label: const Text('Miktar')),
        GridColumn(columnName: 'weight', label: const Text('Ağırlık')),
        GridColumn(columnName: 'volume', label: const Text('Hacim')),
        GridColumn(columnName: 'warehouseId', label: const Text('Depo')),
        GridColumn(columnName: 'originalAMount', label: const Text('Orjinal Dağtım Tutarı')),
        GridColumn(columnName: 'dCurrencyId', label: const Text('Dağıtım Döviz')),
      ],
      columnWidthMode: ColumnWidthMode.auto,
    );
  }
  
  Widget _buildExpenseGrid(ImportExpenseDSource dataSource) {
    return SfDataGrid(
      source: dataSource,
      // allowFiltering: true, // İsteğiniz üzerine kaldırıldı
      
      // --- DÜZELTME BURADA: Dip Toplam ---
      tableSummaryRows: [
        GridTableSummaryRow(
          position: GridTableSummaryRowPosition.bottom,
          columns: [
            GridSummaryColumn(name: 'expenseName', columnName: 'expenseName', summaryType: GridSummaryType.count),
            GridSummaryColumn(name: 'amount', columnName: 'amount', summaryType: GridSummaryType.sum),
            GridSummaryColumn(name: 'distributedAmount', columnName: 'distributedAmount', summaryType: GridSummaryType.sum),
            GridSummaryColumn(name: 'remainingAmount', columnName: 'remainingAmount', summaryType: GridSummaryType.sum),
          ],
        ),
      ],
      // ------------------------------------

      columns: [
        GridColumn(columnName: 'expenseName', label: const Text('Masraf Adı')),
        GridColumn(columnName: 'amount', label: const Text('Tutar')),
        GridColumn(columnName: 'currencyName', label: const Text('Döviz')),
        GridColumn(columnName: 'exchangeRate', label: const Text('Kur')),
        GridColumn(columnName: 'distributedAmount', label: const Text('Dağıtılan')),
        GridColumn(columnName: 'remainingAmount', label: const Text('Kalan')),
      ],
      columnWidthMode: ColumnWidthMode.auto,
    );
  }

  Widget _buildItemsGrid(ImportItemDSource dataSource) {
    return SfDataGrid(
      source: dataSource,
      // allowFiltering: true, // İsteğiniz üzerine kaldırıldı

      // --- DÜZELTME BURADA: Dip Toplam ---
      tableSummaryRows: [
        GridTableSummaryRow(
          position: GridTableSummaryRowPosition.bottom,
          columns: [
            GridSummaryColumn(name: 'itemCode', columnName: 'itemCode', summaryType: GridSummaryType.count),
            GridSummaryColumn(name: 'itemAmount', columnName: 'itemAmount', summaryType: GridSummaryType.sum),
          ],
        ),
      ],
      // ------------------------------------

      columns: [
        GridColumn(columnName: 'itemCode', label: const Text('Stok Kodu')),
        GridColumn(columnName: 'itemName', label: const Text('Stok Adı')),
        GridColumn(columnName: 'quantity', label: const Text('Miktar')),
        GridColumn(columnName: 'unit', label: const Text('Birim')),
        GridColumn(columnName: 'itemAmount', label: const Text('Mal Bedeli')),
        GridColumn(columnName: 'currencyName', label: const Text('Döviz')),
        GridColumn(columnName: 'warehouseId', label: const Text('Depo')),
        GridColumn(columnName: 'hsCode', label: const Text('GTİP Kodu')),
      ],
      columnWidthMode: ColumnWidthMode.auto,
    );
  }
}

// --- DATAGRID KAYNAKLARI (Data Sources) (GÜNCELLENDİ) ---
// Artık N2 formatlamayı ve Dip Toplam HÜCRELERİNİ de yapıyorlar.

// 1. Dağıtılmış Masraflar (Tab 1)
class ImportDistDSource extends DataGridSource {
  final NumberFormat formatter;
  ImportDistDSource({required List<ImportExpenseDistributionDto> items, required this.formatter}) {
    _items = items.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'itemCode', value: e.itemCode),
      DataGridCell<String>(columnName: 'itemName', value: e.itemName),
      DataGridCell<int>(columnName: 'expenseGroup', value: e.expenseGroup),
      DataGridCell<double>(columnName: 'distributedAmount', value: e.distributedAmount),
      DataGridCell<double>(columnName: 'calculatedVatAmount', value: e.calculatedVatAmount),
      DataGridCell<double>(columnName: 'quantity', value: e.quantity),
      DataGridCell<double>(columnName: 'weight', value: e.weight),
      DataGridCell<double>(columnName: 'volume', value: e.volume),
      DataGridCell<int>(columnName: 'warehouseId', value: e.warehouseId),
      DataGridCell<double>(columnName: 'originalAmount', value: e.originalAmount),
      DataGridCell<int>(columnName: 'dCurencyId', value: e.dCurrencyId),
    ])).toList();
  }
  List<DataGridRow> _items = [];
  @override
  List<DataGridRow> get rows => _items;
  
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: row.getCells().map<Widget>((cell) {
      final isNumeric = cell.value is double || cell.value is int;
      String cellValue = cell.value.toString();
      
      // N2 Formatlama (Satır İçi)
      if (cell.value is double) {
        if (cell.columnName == 'distributedAmount' || 
            cell.columnName == 'calculatedVatAmount' ||
            cell.columnName == 'quantity' || // Miktarları da formatlayalım
            cell.columnName == 'weight' ||
            cell.columnName == 'volume') {
          cellValue = formatter.format(cell.value);
        }
      }
      
      return Container(
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft, 
        padding: const EdgeInsets.all(8.0), 
        child: Text(cellValue)
      );
    }).toList());
  }

  // --- YENİ EKLENEN DİP TOPLAM HÜCRESİ OLUŞTURUCU ---
  @override
  Widget? buildTableSummaryCellWidget(
    GridTableSummaryRow summaryRow,
    GridSummaryColumn? summaryColumn,
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    String cellValue = summaryValue;
    Alignment alignment = Alignment.centerLeft;

    // Hangi hücreyi çizdiğimizi kontrol et
    if (summaryColumn?.columnName == 'itemCode') {
      cellValue = 'TOPLAM';
    } 
    else if (summaryColumn?.columnName == 'distributedAmount' || 
             summaryColumn?.columnName == 'calculatedVatAmount') 
    {
      // Gelen 'summaryValue' (örn: "12345.67") string'ini double'a çevirip formatla
      cellValue = formatter.format(double.tryParse(summaryValue) ?? 0);
      alignment = Alignment.centerRight;
    } 
    else {
      cellValue = ''; // Diğer kolonlar için boş
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: alignment,
      child: Text(cellValue, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
  // ---------------------------------
}

// 2. Masraflar (Tab 2)
class ImportExpenseDSource extends DataGridSource {
  final NumberFormat formatter;
  ImportExpenseDSource({required List<ImportExpenseDto> items, required this.formatter}) {
    _items = items.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'expenseName', value: e.expenseName),
      DataGridCell<double>(columnName: 'amount', value: e.amount),
      DataGridCell<String>(columnName: 'currencyName', value: e.currencyName),
      DataGridCell<double>(columnName: 'exchangeRate', value: e.exchangeRate),
      DataGridCell<double>(columnName: 'distributedAmount', value: e.distributedAmount),
      DataGridCell<double>(columnName: 'remainingAmount', value: e.remainingAmount),
    ])).toList();
  }
  List<DataGridRow> _items = [];
  @override
  List<DataGridRow> get rows => _items;
  
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    // ... (buildRow metodu N2 formatlama ile güncellendi) ...
     return DataGridRowAdapter(cells: row.getCells().map<Widget>((cell) {
      final isNumeric = cell.value is double;
      String cellValue = cell.value.toString();
      
      if (isNumeric) {
        // Kur (exchangeRate) hariç tüm sayıları formatla
        if (cell.columnName != 'exchangeRate') {
          cellValue = formatter.format(cell.value);
        }
      }
      
      return Container(
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft, 
        padding: const EdgeInsets.all(8.0), 
        child: Text(cellValue)
      );
    }).toList());
  }

  // --- YENİ EKLENEN DİP TOPLAM HÜCRESİ OLUŞTURUCU ---
  @override
  Widget? buildTableSummaryCellWidget(
    GridTableSummaryRow summaryRow,
    GridSummaryColumn? summaryColumn,
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    String cellValue = summaryValue;
    Alignment alignment = Alignment.centerLeft;

    if (rowColumnIndex.columnIndex == 0) { // 'expenseName' kolonu
      cellValue = 'TOPLAM';
    } 
    else if (summaryColumn?.summaryType == GridSummaryType.sum) {
      cellValue = formatter.format(double.tryParse(summaryValue) ?? 0);
      alignment = Alignment.centerRight;
    } 
    else {
      cellValue = '';
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: alignment,
      child: Text(cellValue, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
  // ---------------------------------
}

// 3. Stoklar (Tab 3)
class ImportItemDSource extends DataGridSource {
  final NumberFormat formatter;
  ImportItemDSource({required List<ImportItemDto> items, required this.formatter}) {
    _items = items.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'itemCode', value: e.itemCode),
      DataGridCell<String>(columnName: 'itemName', value: e.itemName),
      DataGridCell<double>(columnName: 'quantity', value: e.quantity),
      DataGridCell<String>(columnName: 'unit', value: e.unit),
      DataGridCell<double>(columnName: 'itemAmount', value: e.itemAmount),
      DataGridCell<String>(columnName: 'currencyName', value: e.currencyName),
      DataGridCell<int>(columnName: 'warehouseId', value: e.warehouseId),
      DataGridCell<String>(columnName: 'hsCode', value: e.hsCode?.code ?? 'N/A'),
    ])).toList();
  }
  List<DataGridRow> _items = [];
  @override
  List<DataGridRow> get rows => _items;
  
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    // ... (buildRow metodu N2 formatlama ile güncellendi) ...
    return DataGridRowAdapter(cells: row.getCells().map<Widget>((cell) {
      final isNumeric = cell.value is double;
      String cellValue = cell.value.toString();
      
      if (isNumeric) {
        if (cell.columnName == 'itemAmount' || cell.columnName == 'quantity') {
          cellValue = formatter.format(cell.value);
        }
      }
      
      return Container(
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft, 
        padding: const EdgeInsets.all(8.0), 
        child: Text(cellValue)
      );
    }).toList());
  }

  // --- YENİ EKLENEN DİP TOPLAM HÜCRESİ OLUŞTURUCU ---
  @override
  Widget? buildTableSummaryCellWidget(
    GridTableSummaryRow summaryRow,
    GridSummaryColumn? summaryColumn,
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    String cellValue = summaryValue;
    Alignment alignment = Alignment.centerLeft;

    if (rowColumnIndex.columnIndex == 0) { // 'itemCode' kolonu
      cellValue = 'TOPLAM';
    } 
    else if (summaryColumn?.columnName == 'itemAmount') {
      cellValue = formatter.format(double.tryParse(summaryValue) ?? 0);
      alignment = Alignment.centerRight;
    } 
    else {
      cellValue = '';
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: alignment,
      child: Text(cellValue, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
  // ---------------------------------
}