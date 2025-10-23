// lib/screens/bank_credits_barchart_screen.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/bank_credits_vm.dart';

class _ChartData {
  _ChartData(this.bankCode, this.totalAmount);
  final String bankCode;
  final double totalAmount;
}

class BankCreditsBarChartScreen extends StatelessWidget {
  final String pageTitle;
  final List<BankCreditsVM> details;

  const BankCreditsBarChartScreen({super.key, required this.pageTitle, required this.details});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> groupedData = {};
    for (var detail in details) {
      groupedData[detail.bankCode] = (groupedData[detail.bankCode] ?? 0) + detail.amountTl;
    }
    final List<_ChartData> chartDataSource = groupedData.entries.map((e) => _ChartData(e.key, e.value)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle), backgroundColor: Colors.indigo),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(),
            primaryYAxis: NumericAxis(numberFormat: NumberFormat.compactSimpleCurrency(locale: 'tr_TR')),
            title: ChartTitle(text: 'Banka Bazında Toplam Krediler'),
            series: <CartesianSeries<_ChartData, String>>[
              ColumnSeries<_ChartData, String>(
                dataSource: chartDataSource,
                xValueMapper: (_ChartData data, _) => data.bankCode,
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