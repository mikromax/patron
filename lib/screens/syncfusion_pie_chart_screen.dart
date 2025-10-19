import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Syncfusion Charts kütüphanesi
import '../models/nakit_varliklar_model.dart';

// Syncfusion grafiğinin anlayacağı veri yapısı için bir yardımcı sınıf
class _ChartData {
  _ChartData(this.x, this.y, this.text);
  final String x; // Dilimin etiketi (Örn: "Banka A")
  final double y; // Dilimin değeri (Örn: 150500.00)
  final String text; // Dilimin üzerinde görünecek metin (Örn: "45%")
}

class SyncfusionPieChartScreen extends StatelessWidget {
  final List<Detail> details;

  const SyncfusionPieChartScreen({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    // Toplam değeri hesaplayalım ki yüzdeleri bulabilelim
    final double totalValue = details.fold(0.0, (sum, item) => sum + item.amountTl);

    // API'den gelen 'Detail' listesini grafiğin anlayacağı '_ChartData' listesine dönüştürelim
    final List<_ChartData> chartDataSource = details
      // Değeri 0'dan büyük olanları alalım ki grafikte anlamsız dilimler olmasın
      .where((detail) => detail.amountTl > 0) 
      .map((detail) {
        final percentage = (detail.amountTl / totalValue) * 100;
        // Açıklama çok uzunsa kısaltalım
        final label = detail.definition.length > 20 
            ? '${detail.definition.substring(0, 18)}...' 
            : detail.definition;
        return _ChartData(label, detail.amountTl, '${percentage.toStringAsFixed(1)}%');
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Varlık Dağılımı (Syncfusion)'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: SfCircularChart(
            title: ChartTitle(text: 'Nakit Varlıkların Hesaba Göre Dağılımı'),
            // Grafiğin altındaki açıklamalar (legend)
            legend: const Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
            // Grafiğin kendisi
            series: <CircularSeries<_ChartData, String>>[
              PieSeries<_ChartData, String>(
                dataSource: chartDataSource,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                // Dilimlerin üzerinde yüzdeleri göstermek için
                dataLabelMapper: (_ChartData data, _) => data.text,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                ),
                // Dilimleri birbirinden biraz ayırarak daha şık göster
                explode: true, 
              )
            ],
          ),
        ),
      ),
    );
  }
}