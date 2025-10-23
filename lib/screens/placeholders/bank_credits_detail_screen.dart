// lib/screens/placeholders/bank_credits_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bank_credits_vm.dart';

class BankCreditsDetailScreen extends StatelessWidget {
  final String pageTitle;
  final List<BankCreditsVM> details;

  const BankCreditsDetailScreen({super.key, required this.pageTitle, required this.details});

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

  Widget _buildDetailCard(BuildContext context, BankCreditsVM detail) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Banka: ${detail.bankCode} - Kredi: ${detail.creditCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Para Birimi: ${detail.currency}'),
                Text(currencyFormatter.format(detail.amountTl), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}