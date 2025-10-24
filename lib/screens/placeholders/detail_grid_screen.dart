import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/nakit_varliklar_model.dart';
import 'package:intl/intl.dart';
import 'statement_page_screen.dart'; // Yeni Föy sayfasını import ediyoruz

class DetailGridScreen extends StatelessWidget {
  final String pageTitle;
  final List<Detail> details;

  const DetailGridScreen({super.key, required this.pageTitle, required this.details});

  // Excel ve Mail fonksiyonları aynı kalıyor, onlara dokunmuyoruz.
  // ... (_exportToExcelAndShare ve _sendMail fonksiyonları burada)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // Export ve Mail Butonları aynı kalıyor
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _exportToExcelAndShare(context),
                  icon: const Icon(Icons.grid_on),
                  label: const Text("Excel'e Aktar"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _sendMail,
                  icon: const Icon(Icons.mail),
                  label: const Text("Mail Gönder"),
                ),
              ],
            ),
          ),
          
          // --- DEĞİŞİKLİK BURADA: DataTable yerine ListView.builder ---
          Expanded(
            child: ListView.builder(
              itemCount: details.length,
              itemBuilder: (context, index) {
                final detail = details[index];
                return _buildDetailCard(context, detail); // Her bir eleman için kart oluştur
              },
            ),
          ),
        ],
      ),
    );
  }

  // Her bir detayı bir kart içinde gösteren yardımcı widget
  Widget _buildDetailCard(BuildContext context, Detail detail) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final numberFormatter = NumberFormat("#,##0.00", "tr_TR");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Satır: Kod, Tanım ve Para Birimi
            Row(
              children: [
                Text('${detail.code} -', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(detail.definition, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(detail.currency, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 20),
            // 2. Satır: Tutarlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountColumn('Orijinal Tutar', '${numberFormatter.format(detail.amountOriginal)} ${detail.currency}'),
                _buildAmountColumn('TL Karşılığı', currencyFormatter.format(detail.amountTl)),
              ],
            ),
            const SizedBox(height: 12),
            // 3. Satır: Föy Butonu
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatementPageScreen(detail: detail,context: StatementContext.cash,),
                    ),
                  );
                },
                child: const Text('Föy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tutarları ve başlıklarını bir sütun içinde gösteren yardımcı widget
  Widget _buildAmountColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  // --- Buraya _exportToExcelAndShare ve _sendMail fonksiyonlarını tekrar ekleyin ---
  // (Önceki yanıtlardaki tam hallerini kopyalayıp buraya yapıştırabilirsiniz)
  Future<void> _exportToExcelAndShare(BuildContext context) async {
    var excel = Excel.createExcel();
    String sheetName = excel.getDefaultSheet()!;
    Sheet sheetObject = excel[sheetName];
  

    CellStyle headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('FFC5CAE9')
    );
    
    List<String> headerList = ['Açıklama', 'Para Birimi', 'Orijinal Tutar', 'TL Karşılığı'];
    List<CellValue> headerRow = headerList.map((col) => TextCellValue(col)).toList();
    sheetObject.appendRow(headerRow);
    
    for (var i = 0; i < headerRow.length; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
    }

    for (var detail in details) {
      var row = [
        TextCellValue(detail.definition),
        TextCellValue(detail.currency),
        DoubleCellValue(detail.amountOriginal),
        DoubleCellValue(detail.amountTl),
      ];
      sheetObject.appendRow(row);
    }
    
  
    final directory = await getTemporaryDirectory();
    final fileName = 'nakit_varliklar_raporu_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final path = '${directory.path}/$fileName';
    
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      
      if (!context.mounted) return;
      await Share.shareXFiles([XFile(file.path)], text: '$pageTitle Raporu');
    }
  }

  Future<void> _sendMail() async {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    String body = '$pageTitle Raporu:\n\n';
    body += '-------------------------------------------------\n';
    for (var detail in details) {
      body += 'Açıklama: ${detail.definition}\n';
      body += 'Tutar: ${detail.amountOriginal.toStringAsFixed(2)} ${detail.currency}\n';
      body += 'TL Karşılığı: ${currencyFormatter.format(detail.amountTl)}\n';
      body += '-------------------------------------------------\n';
    }
    final Uri mailUri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': '$pageTitle Raporu - ${DateFormat('dd.MM.yyyy').format(DateTime.now())}',
        'body': body,
      },
    );
    if (await canLaunchUrl(mailUri)) {
      await launchUrl(mailUri);
    } else {
      throw 'Mail uygulaması bulunamadı.';
    }
  }
}