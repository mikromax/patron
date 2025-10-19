import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DynamicDataGridScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;

  const DynamicDataGridScreen({super.key, required this.title, required this.data});

  Future<void> _exportToExcelAndShare(BuildContext context) async {
    if (data.isEmpty) return;
    var excel = Excel.createExcel();
    Sheet sheetObject = excel[excel.getDefaultSheet()!];
   

    // Başlıkları verinin ilk satırının anahtarlarından dinamik olarak al
    List<String> headerList = data.first.keys.toList();
    sheetObject.appendRow(headerList.map((col) => TextCellValue(col)).toList());

    // Veri satırlarını dinamik olarak ekle
    for (var rowData in data) {
      List<CellValue> row = headerList.map((key) {
        final value = rowData[key];
        if (value is num) {
          return DoubleCellValue(value.toDouble());
        }
        return TextCellValue(value.toString());
      }).toList();
      sheetObject.appendRow(row);
    }
    
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/ai_raporu_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(path)..writeAsBytesSync(fileBytes);
      if (!context.mounted) return;
      await Share.shareXFiles([XFile(file.path)], text: title);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text(title)), body: const Center(child: Text('Görüntülenecek veri yok.')));
    }

    // Kolon başlıklarını ilk veri satırından al
    final columns = data.first.keys.map((key) => DataColumn(label: Text(key))).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: "Excel'e Aktar",
            onPressed: () => _exportToExcelAndShare(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns,
            rows: data.map((rowData) {
              return DataRow(
                cells: rowData.values.map((cellData) {
                  return DataCell(Text(cellData.toString()));
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}