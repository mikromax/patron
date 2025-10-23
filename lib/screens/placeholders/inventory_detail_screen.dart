import 'package:flutter/material.dart';
import '../../models/inventory_status_dto.dart';
import 'package:intl/intl.dart';
// Gerekli import'ları ekliyoruz
import '../../models/nakit_varliklar_model.dart';
import 'statement_page_screen.dart';

class InventoryDetailScreen extends StatelessWidget {
  final String pageTitle;
  final List<InventoryStatusDto> details;

  const InventoryDetailScreen({super.key, required this.pageTitle, required this.details});

  @override
  Widget build(BuildContext context) {
    // --- VERİ GRUPLAMA MANTIĞI ---
    final Map<String, List<InventoryStatusDto>> groupedByItemCode = {};
    for (var detail in details) {
      if (groupedByItemCode.containsKey(detail.itemCode)) {
        groupedByItemCode[detail.itemCode]!.add(detail);
      } else {
        groupedByItemCode[detail.itemCode] = [detail];
      }
    }
    final itemCodes = groupedByItemCode.keys.toList();
    // --- GRUPLAMA SONU ---

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle), backgroundColor: Colors.indigo),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: itemCodes.length,
        itemBuilder: (context, index) {
          final itemCode = itemCodes[index];
          final items = groupedByItemCode[itemCode]!;
          return _buildGroupedCard(context, items);
        },
      ),
    );
  }

  Widget _buildGroupedCard(BuildContext context, List<InventoryStatusDto> items) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    // Grubun toplam miktarını ve tutarını hesapla
    final totalQuantity = items.fold(0.0, (sum, item) => sum + item.quantity);
    final totalAmount = items.fold(0.0, (sum, item) => sum + item.amountTl);
    // Bu stoğun bulunduğu depoları listele
    final warehouses = items.map((item) => item.warehouse).toSet().join(', ');
    final firstItem = items.first;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${firstItem.itemCode} - ${firstItem.itemName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Depolar: $warehouses', style: TextStyle(color: Colors.grey.shade600, fontSize: 12), overflow: TextOverflow.ellipsis),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Toplam Miktar', totalQuantity.toString()),
                _buildInfoColumn('Toplam Tutar (TL)', currencyFormatter.format(totalAmount), alignRight: true),
              ],
            ),
            const SizedBox(height: 8),
            // Yeni İkon Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.list_alt), tooltip: 'Föy', onPressed: () => _navigateToStatement(context, firstItem)),
                IconButton(icon: const Icon(Icons.arrow_downward), tooltip: 'Son 10 Giriş', onPressed: () => _navigateToPlaceholder(context, 'Son 10 Giriş')),
                IconButton(icon: const Icon(Icons.arrow_upward), tooltip: 'Son 10 Çıkış', onPressed: () => _navigateToPlaceholder(context, 'Son 10 Çıkış')),
                IconButton(icon: const Icon(Icons.sell_outlined), tooltip: 'Fiyat Listesi', onPressed: () => _navigateToPlaceholder(context, 'Fiyat Listesi')),
                IconButton(icon: const Icon(Icons.inventory_2_outlined), tooltip: 'Bekleyen Siparişler', onPressed: () => _navigateToPlaceholder(context, 'Bekleyen Siparişler')),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Yardımcı widget'lar
  Widget _buildInfoColumn(String title, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  void _navigateToPlaceholder(BuildContext context, String title) { /* ... */ }
  
  void _navigateToStatement(BuildContext context, InventoryStatusDto item) {
    // Föy sayfası 'Detail' beklediği için geçici bir nesne oluşturuyoruz.
    // Bu, gelecekte Föy sayfasını daha jenerik hale getirerek iyileştirilebilir.
    final tempDetail = Detail(code: item.itemCode, definition: item.itemName, currency: '', amountOriginal: 0, amountTl: item.amountTl);
    Navigator.push(context, MaterialPageRoute(builder: (context) => StatementPageScreen(detail: tempDetail)));
  }
}