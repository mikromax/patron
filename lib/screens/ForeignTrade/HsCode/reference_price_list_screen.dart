import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/ForeignTrade/HsCode/hs_code_reference_price_dto.dart';
import '../../../services/api/ForeignTrade/hscode_api.dart';
import 'add_edit_price_screen.dart';

class ReferencePriceListScreen extends StatefulWidget {
  final String hsCodeId;
  final String hsCodeDescription;

  const ReferencePriceListScreen({
    super.key,
    required this.hsCodeId,
    required this.hsCodeDescription,
  });

  @override
  State<ReferencePriceListScreen> createState() => _ReferencePriceListScreenState();
}

class _ReferencePriceListScreenState extends State<ReferencePriceListScreen> {
  final HsCodeApi _api = HsCodeApi();
  late Future<List<HsCodeReferencePriceDto>> _pricesFuture;
  bool _includeExpired = false; // Geçmiş kayıtları göster/gizle state'i

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() {
    setState(() {
      _pricesFuture = _api.getHsCodeReferencePrices(widget.hsCodeId, includeExpired: _includeExpired);
    });
    return _pricesFuture;
  }
// "Ekle" veya "Düzenle" ekranına gitmek için ortak fonksiyon
  void _navigateToAddEditScreen({HsCodeReferencePriceDto? price}) async {
    // Yeni ekrandan 'true' değeri dönerse listeyi yenile
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPriceScreen(
          hsCodeId: widget.hsCodeId,
          existingPrice: price, // "Ekle" modunda bu 'null' olacak
        ),
      ),
    );

    if (result == true) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hsCodeDescription, style: const TextStyle(fontSize: 16)),
        actions: [
          // Geçmişi Göster/Gizle butonu
          Tooltip(
            message: _includeExpired ? 'Geçmişi Gizle' : 'Geçmişi Göster',
            child: IconButton(
              icon: Icon(_includeExpired ? Icons.history_toggle_off : Icons.history),
              onPressed: () {
                setState(() {
                  _includeExpired = !_includeExpired;
                  _fetchData();
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(), // "Ekle" modunda aç
        tooltip: 'Yeni Fiyat Ekle',
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<HsCodeReferencePriceDto>>(
        future: _pricesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Referans fiyat bulunamadı.'));
          }

          final prices = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: prices.length,
            itemBuilder: (context, index) {
              return _buildPriceCard(prices[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildPriceCard(HsCodeReferencePriceDto price) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '');
    final dateFormatter = DateFormat('dd.MM.yyyy');
    final isExpired = price.endDate != null && price.endDate!.isBefore(DateTime.now());

    return Card(
      color: isExpired ? Colors.grey.shade200 : null,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        // Kartın tamamına tıklanabilir
        onTap: isExpired ? null : () => _navigateToAddEditScreen(price: price), // "Düzenle" modunda aç
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${currencyFormatter.format(price.price)} ${price.currencyCode}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 20,
                      color: isExpired ? Colors.grey.shade700 : Colors.black87,
                    ),
                  ),
                  if (isExpired)
                    const Icon(Icons.archive, color: Colors.grey)
                  else
                    const Icon(Icons.edit, color: Colors.blue), // Düzenlenebilir olduğunu göster
                ],
              ),
              const SizedBox(height: 8),
              Text(price.scopeTypeName, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (price.countryList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Ülkeler: ${price.countryList.map((c) => c.countryCode).join(', ')}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ),
              const Divider(height: 16),
            // Satır 3: Tarihler
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: isExpired ? Colors.grey.shade700 : Colors.green),
                Text(
                  ' Başlangıç: ${dateFormatter.format(price.startDate)}',
                  style: TextStyle(color: isExpired ? Colors.grey.shade700 : Colors.green, fontSize: 12),
                ),
                const Spacer(),
                if (price.endDate != null)
                  Icon(Icons.calendar_view_month_sharp, size: 14, color: Colors.grey.shade700),
                if (price.endDate != null)
                  Text(
                    ' Bitiş: ${dateFormatter.format(price.endDate!)}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}