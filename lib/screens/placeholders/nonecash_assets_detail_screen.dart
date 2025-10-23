// lib/screens/placeholders/nonecash_assets_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/nonecash_assets_vm.dart';

class NonecashAssetsDetailScreen extends StatelessWidget {
  final String pageTitle;
  final List<NonecashAssetsVM> details;

  const NonecashAssetsDetailScreen({super.key, required this.pageTitle, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle), backgroundColor: Colors.indigo),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: details.length,
        itemBuilder: (context, index) => _buildDetailCard(context, details[index]),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, NonecashAssetsVM detail) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evrak Tipi: ${detail.doctype}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Pozisyon: ${detail.position}', style: TextStyle(color: Colors.grey.shade600)),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Adet: ${detail.doccount}'),
                Text(currencyFormatter.format(detail.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}