import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/nakit_varliklar_model.dart'; // Detail sınıfına erişmek için

class DetailScreen extends StatelessWidget {
  // Bu ekran, bir liste dolusu 'Detail' nesnesi bekliyor.
  final List<Detail> details;

  // Constructor ile bu listeyi alıyoruz.
  const DetailScreen({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nakit Varlık Detayları'),
        backgroundColor: Colors.indigo,
      ),
      // ListView.builder, uzun listeler için en verimli yöntemdir.
      // Ekranda göründüğü kadar eleman çizer.
      body: ListView.builder(
        itemCount: details.length, // Listede kaç eleman varsa o kadar satır oluştur
        itemBuilder: (context, index) {
          final detailItem = details[index]; // Sıradaki detayı al

          // Her bir detay için şık bir liste elemanı (ListTile) oluşturuyoruz.
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              title: Text(
                detailItem.definition, 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              subtitle: Text(
                '${detailItem.amountOriginal.toStringAsFixed(2)} ${detailItem.currency}'
              ),
              trailing: Text(
                currencyFormatter.format(detailItem.amountTl), // TL karşılığı
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}