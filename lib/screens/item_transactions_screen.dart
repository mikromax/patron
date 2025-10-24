import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item_transaction_dto.dart';

// --- YENİ EKLENEN BÖLÜM 1: EKRANIN MODUNU TANIMLAMA ---
enum TransactionScreenMode { statement, lastEntries, lastExits }

class ItemTransactionsScreen extends StatelessWidget {
  final String pageTitle;
  final Future<List<ItemTransactionDto>> transactionsFuture;
  // --- YENİ EKLENEN BÖLÜM 2: CONSTRUCTOR'A YENİ PARAMETRE ---
  final TransactionScreenMode mode;

  const ItemTransactionsScreen({
    super.key, 
    required this.pageTitle, 
    required this.transactionsFuture,
    required this.mode, // Bu parametre artık zorunlu
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: FutureBuilder<List<ItemTransactionDto>>(
        future: transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Bu kriterlere uygun hareket bulunamadı.'));
          }
          final transactions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) => _buildTransactionCard(transactions[index]),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(ItemTransactionDto transaction) {
    final dateFormatter = DateFormat('dd.MM.yyyy');
    
    // --- YENİ EKLENEN BÖLÜM 3: AKILLI MANTIK ---
    bool isEntry;
    // Ekranın hangi modda olduğuna göre karar ver
    switch (mode) {
      case TransactionScreenMode.lastEntries:
        isEntry = true;
        break;
      case TransactionScreenMode.lastExits:
        isEntry = false;
        break;
      case TransactionScreenMode.statement:
        // Föy modundaysak, miktara göre karar ver
        isEntry = transaction.quantity >= 0;
        break;
    }
    // --- YENİ MANTIK SONU ---

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEntry ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(isEntry ? Icons.arrow_downward : Icons.arrow_upward, color: isEntry ? Colors.green : Colors.red),
        ),
        title: Text('${transaction.account} - ${transaction.documentType}'),
        subtitle: Text('Tarih: ${dateFormatter.format(transaction.transactionDate)} | Depo: ${transaction.wareHouse}'),
        trailing: Text(
          '${transaction.quantity} ${transaction.unit}', // Artık +/- işareti koymuyoruz, renk yeterli
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isEntry ? Colors.green : Colors.red),
        ),
      ),
    );
  }
}