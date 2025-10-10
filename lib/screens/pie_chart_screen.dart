import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/nakit_varliklar_model.dart';

class PieChartScreen extends StatefulWidget {
  final List<Detail> details;

  const PieChartScreen({super.key, required this.details});

  @override
  State<PieChartScreen> createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  int? touchedIndex;
  bool _animate = false;

  final List<Color> pastelColors = [
    const Color(0xFFB2DFDB), // Pastel Teal
    const Color(0xFFFFCCBC), // Pastel Deep Orange
    const Color(0xFFC5CAE9), // Pastel Indigo
    const Color(0xFFFFF9C4), // Pastel Yellow
    const Color(0xFFF8BBD0), // Pastel Pink
    const Color(0xFFD7CCC8), // Pastel Brown
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _animate = true;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Varlık Dağılımı (Animasyonlu)'),
        backgroundColor: Colors.indigo,
      ),
      body: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: PieChart(
                  // DEĞİŞİKLİK BURADA: Animasyon parametreleri PieChart'a taşındı
                  swapAnimationDuration: const Duration(milliseconds: 800),
                  swapAnimationCurve: Curves.easeInOutQuint,
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 0,
                    sections: _generateChartSections(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                alignment: WrapAlignment.center,
                children: _generateLegend(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateChartSections() {
    return List.generate(widget.details.length, (index) {
      final detail = widget.details[index];
      final isTouched = (index == touchedIndex);
      final double fontSize = isTouched ? 20.0 : 14.0;
      final double radius = isTouched ? 90.0 : 80.0;
      final color = pastelColors[index % pastelColors.length];
      
      final double value = _animate ? detail.amountTl : 0;
      final String title = _animate ? '${(detail.amountTl / widget.details.fold(0, (sum, item) => sum + item.amountTl) * 100).toStringAsFixed(1)}%' : '';

      return PieChartSectionData(
        color: color,
        value: value, 
        title: title, 
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
        ),
      );
    });
  }

  List<Widget> _generateLegend() {
    return List.generate(widget.details.length, (index) {
      final detail = widget.details[index];
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 16, height: 16, color: pastelColors[index % pastelColors.length]),
          const SizedBox(width: 4),
          Text(detail.definition),
        ],
      );
    });
  }
}