import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/account_credit_debit_status_dto.dart';

// Syncfusion grafiğinin anlayacağı, gruplanmış veri yapısı için bir yardımcı sınıf
class _ChartData {
  _ChartData(this.currency, this.totalAmount);
  final String currency; // X ekseni: Para Birimi (TRY, USD, EUR)
  final double totalAmount; // Y ekseni: Toplam TL Karşılığı
}

class CreditDebitBarChartScreen extends StatelessWidget {
  final String pageTitle;
  final List<AccountCreditDebitStatusDto> details;

  const CreditDebitBarChartScreen({super.key, required this.pageTitle, required this.details});

  @override
  Widget build(BuildContext context) {
    // --- VERİ GRUPLAMA MANTIĞI ---
    // 1. Para birimlerine göre toplamları tutacak bir Map oluştur.
    final Map<String, double> groupedData = {};

    // 2. Gelen tüm detay listesini döngüye al.
    for (var detail in details) {
      // 3. Map'te bu para birimi zaten var mı diye kontrol et.
      if (groupedData.containsKey(detail.currency)) {
        // Varsa, mevcut toplama bu satırın TL tutarını ekle.
        groupedData[detail.currency] = groupedData[detail.currency]! + detail.amountTl;
      } else {
        // Yoksa, yeni bir giriş oluştur.
        groupedData[detail.currency] = detail.amountTl;
      }
    }

    // 4. Gruplanmış Map'i, grafiğin anlayacağı _ChartData listesine dönüştür.
    final List<_ChartData> chartDataSource = groupedData.entries.map((entry) {
      return _ChartData(entry.key, entry.value);
    }).toList();
    // --- GRUPLAMA SONU ---

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(), // X ekseni kategorik (para birimleri)
            primaryYAxis: NumericAxis(
              // Y eksenindeki sayıları para formatında göster
              numberFormat: NumberFormat.compactSimpleCurrency(locale: 'tr_TR'),
            ),
            title: ChartTitle(text: 'Para Birimi Bazında Toplamlar'),
            tooltipBehavior: TooltipBehavior(enable: true), // Sütunların üzerine gelince değeri göster
            series: <CartesianSeries<_ChartData, String>>[
              ColumnSeries<_ChartData, String>(
                dataSource: chartDataSource,
                xValueMapper: (_ChartData data, _) => data.currency,
                yValueMapper: (_ChartData data, _) => data.totalAmount,
                name: pageTitle,
                // Sütunların üzerinde değerleri göster
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              )
            ],
          ),
        ),
      ),
    );
  }
}