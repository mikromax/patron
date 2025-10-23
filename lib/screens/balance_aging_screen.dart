// lib/screens/balance_aging_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/balance_aging_chart_item_vm.dart';
import '../models/balance_aging_chart_vm.dart';
import '../models/get_account_balance_aging_chart_query.dart';
import '../services/api_service.dart';

class BalanceAgingScreen extends StatefulWidget {
  final String accountCode;
  final String accountName;

  const BalanceAgingScreen({super.key, required this.accountCode, required this.accountName});

  @override
  State<BalanceAgingScreen> createState() => _BalanceAgingScreenState();
}

class _BalanceAgingScreenState extends State<BalanceAgingScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<BalanceAgingChartVM>> _agingFuture;

  @override
  void initState() {
    super.initState();
    _agingFuture = _fetchData();
  }

  Future<List<BalanceAgingChartVM>> _fetchData() {
    return _apiService.getAccountBalanceAgingChart(GetAccountBalanceAgingChartQuery(accountCode: widget.accountCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.accountName} - Yaşlandırma')),
      body: FutureBuilder<List<BalanceAgingChartVM>>(
        future: _agingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Yaşlandırma verisi bulunamadı.'));
          }

          final agingDataList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: agingDataList.length,
            itemBuilder: (context, index) {
              return _buildAgingCard(context, agingDataList[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildAgingCard(BuildContext context, BalanceAgingChartVM data) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormatter = DateFormat('dd.MM.yyyy');
    final today = DateTime.now();
    // Vade tarihinin bugünle karşılaştırılması (sadece gün, ay, yıl)
    final isTotalOverdue = DateTime(data.dueDate.year, data.dueDate.month, data.dueDate.day).isBefore(DateTime(today.year, today.month, today.day));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Para Birimi: ${data.currency}', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              title: 'Gecikmiş Bakiye',
              amount: data.overdueAmount,
              date: data.overdueDate,
              color: Colors.red,
              items: data.items.where((item) => item.dueDate.isBefore(today)).toList(),
              currencyFormatter: currencyFormatter,
              dateFormatter: dateFormatter,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              title: 'Vadesi Gelmemiş Bakiye',
              amount: data.outstandingAmount,
              date: data.outstandingDate,
              color: Colors.blue,
              items: data.items.where((item) => !item.dueDate.isBefore(today)).toList(),
              currencyFormatter: currencyFormatter,
              dateFormatter: dateFormatter,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              title: 'Toplam Bakiye',
              amount: data.totalAmount,
              date: data.dueDate,
              color: isTotalOverdue ? Colors.red : Colors.blue,
              items: data.items,
              currencyFormatter: currencyFormatter,
              dateFormatter: dateFormatter,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required String title, required double amount, required DateTime date, required Color color, required List<BalanceAgingChartItemVM> items, required NumberFormat currencyFormatter, required DateFormat dateFormatter, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
            Text('Vade: ${dateFormatter.format(date)}', style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
        Row(
          children: [
            Text(currencyFormatter.format(amount), style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14, color: color)),
            IconButton(
              icon: const Icon(Icons.list, color: Colors.grey),
              onPressed: () => _showItemDetails(context, title, items, currencyFormatter),
            ),
          ],
        ),
      ],
    );
  }

  void _showItemDetails(BuildContext context, String title, List<BalanceAgingChartItemVM> items, NumberFormat currencyFormatter) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.period),
                    trailing: Text(currencyFormatter.format(item.amount)),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}