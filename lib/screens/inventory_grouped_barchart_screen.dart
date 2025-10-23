import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/inventory_status_dto.dart';

// Grafiğin anlayacağı, gruplanmış veri yapısı
class _GroupedChartData {
  _GroupedChartData(this.groupName, this.totalQuantity, this.totalAmount);
  final String groupName;
  double totalQuantity;
  double totalAmount;
}

class InventoryGroupedBarChartScreen extends StatelessWidget {
  final String pageTitle;
  final List<InventoryStatusDto> details;
  final String groupBy; // 'warehouse', 'itemGroup', veya 'brand' olabilir

  const InventoryGroupedBarChartScreen({
    super.key,
    required this.pageTitle,
    required this.details,
    required this.groupBy,
  });

  @override
  Widget build(BuildContext context) {
    // --- VERİ GRUPLAMA MANTIĞI ---
    final Map<String, _GroupedChartData> groupedData = {};

    for (var detail in details) {
      String key;
      // Hangi kritere göre gruplanacağını belirliyoruz
      if (groupBy == 'warehouse') {
        key = detail.warehouse;
      } else if (groupBy == 'itemGroup') {
        key = detail.itemGroup;
      } else { // brand
        key = detail.brand;
      }

      if (groupedData.containsKey(key)) {
        groupedData[key]!.totalQuantity += detail.quantity;
        groupedData[key]!.totalAmount += detail.amountTl;
      } else {
        groupedData[key] = _GroupedChartData(key, detail.quantity, detail.amountTl);
      }
    }
    final List<_GroupedChartData> chartDataSource = groupedData.values.toList();
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
            primaryXAxis: const CategoryAxis(
              labelIntersectAction: AxisLabelIntersectAction.rotate45, // Etiketler sığmazsa 45 derece döndür
            ),
            // İki farklı Y ekseni tanımlıyoruz: Biri Miktar, diğeri Tutar için
            axes: const <ChartAxis>[
              NumericAxis(
                name: 'quantityAxis',
                title: AxisTitle(text: 'Miktar'),
                opposedPosition: true, // Sağ tarafta göster
              ),
            ],
            title: ChartTitle(text: '$pageTitle Raporu'),
            legend: const Legend(isVisible: true, position: LegendPosition.bottom),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<_GroupedChartData, String>>[
              // Tutar için Sütun Serisi (Ana Y eksenini kullanır)
              ColumnSeries<_GroupedChartData, String>(
                dataSource: chartDataSource,
                xValueMapper: (_GroupedChartData data, _) => data.groupName,
                yValueMapper: (_GroupedChartData data, _) => data.totalAmount,
                name: 'Toplam Tutar (TL)',
                dataLabelSettings: const DataLabelSettings(isVisible: true, angle: -90, textStyle: TextStyle(fontSize: 10)),
              ),
              // Miktar için Sütun Serisi (İkincil 'quantityAxis' eksenini kullanır)
              ColumnSeries<_GroupedChartData, String>(
                dataSource: chartDataSource,
                xValueMapper: (_GroupedChartData data, _) => data.groupName,
                yValueMapper: (_GroupedChartData data, _) => data.totalQuantity,
                yAxisName: 'quantityAxis', // Hangi Y eksenini kullanacağını belirt
                name: 'Toplam Miktar',
                dataLabelSettings: const DataLabelSettings(isVisible: true, angle: -90, textStyle: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}