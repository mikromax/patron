import 'package:flutter/material.dart';
import '../models/scorecard_model.dart';
import '../screens/placeholders/generic_placeholder_screen.dart';

class ScorecardWidget extends StatelessWidget {
  final ScorecardModel model;

  const ScorecardWidget({super.key, required this.model});

  void _navigateTo(BuildContext context, String pageTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenericPlaceholderScreen(pageTitle: pageTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Kısım (İkon, Başlık, Değer)
            Row(
              children: [
                Icon(model.icon, size: 40, color: model.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text(model.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(), // Butonları aşağı itmek için boşluk
            // Alt Kısım (Butonlar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Detay Butonu
                IconButton(
                  icon: const Icon(Icons.grid_on, color: Colors.black54),
                  tooltip: 'Detay Grid',
                  onPressed: () => _navigateTo(context, '${model.title} - Detay Grid'),
                ),
                // Grafik Butonu
                IconButton(
                  icon: const Icon(Icons.pie_chart, color: Colors.black54),
                  tooltip: 'Grafik',
                  onPressed: () => _navigateTo(context, '${model.title} - Grafik'),
                ),
                // Popup Menü Butonu
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert, color: Colors.black54),
                  tooltip: 'Diğer Seçenekler',
                  onSelected: (value) {
                    _navigateTo(context, '${model.title} - Menu $value');
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 1, child: Text('Menu 1')),
                    const PopupMenuItem(value: 2, child: Text('Menu 2')),
                    const PopupMenuItem(value: 3, child: Text('Menu 3')),
                    const PopupMenuItem(value: 4, child: Text('Menu 4')),
                    const PopupMenuItem(value: 5, child: Text('Menu 5')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}