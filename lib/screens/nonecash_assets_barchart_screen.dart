// lib/screens/nonecash_assets_barchart_screen.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/nonecash_assets_vm.dart';

class _ChartData {
  _ChartData(this.groupName, this.totalAmount);
  final String groupName;
  final double totalAmount;
}

class NonecashAssetsBarChartScreen extends StatelessWidget {
  final String pageTitle;
  final List<NonecashAssetsVM> details;
  final String groupBy; // 'doctype' veya 'position'

  const NonecashAssetsBarChartScreen({super.key, required this.pageTitle, required this.details, required this.groupBy});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> groupedData = {};
    for (var detail in details) {
      String key = (groupBy == 'doctype') ? detail.doctype : detail.position;
      groupedData[key] = (groupedData[key] ?? 0) + detail.amount;
    }
    final List<_ChartData> chartDataSource = groupedData.entries.map((e) => _ChartData(e.key, e.value)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle), backgroundColor: Colors.indigo),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelIntersectAction: AxisLabelIntersectAction.rotate45),
            primaryYAxis: NumericAxis(numberFormat: NumberFormat.compactSimpleCurrency(locale: 'tr_TR')),
            title: ChartTitle(text: pageTitle),
            series: <CartesianSeries<_ChartData, String>>[
              ColumnSeries<_ChartData, String>(
                dataSource: chartDataSource,
                xValueMapper: (_ChartData data, _) => data.groupName,
                yValueMapper: (_ChartData data, _) => data.totalAmount,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              )
            ],
          ),
        ),
      ),
    );
  }
}