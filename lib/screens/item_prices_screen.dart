// lib/screens/item_prices_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/get_item_prices_query.dart';
import '../models/item_price_dto.dart';
import '../services/api/inventory_api.dart';

class ItemPricesScreen extends StatefulWidget {
  final String itemCode;
  final String itemName;

  const ItemPricesScreen({super.key, required this.itemCode, required this.itemName});

  @override
  State<ItemPricesScreen> createState() => _ItemPricesScreenState();
}

class _ItemPricesScreenState extends State<ItemPricesScreen> {
  final InventoryApi _apiService = InventoryApi();
  late Future<List<ItemPriceDto>> _pricesFuture;

  @override
  void initState() {
    super.initState();
    _pricesFuture = _fetchPrices();
  }

  Future<List<ItemPriceDto>> _fetchPrices() {
    return _apiService.getItemAllPrices(GetItemPricesQuery(itemCode: widget.itemCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.itemName} - Fiyat Listesi')),
      body: FutureBuilder<List<ItemPriceDto>>(
        future: _pricesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Bu stoka ait fiyat bilgisi bulunamadı.'));
          }

          final prices = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: prices.length,
            itemBuilder: (context, index) {
              final priceItem = prices[index];
              final numberFormatter = NumberFormat("#,##0.00", "tr_TR");
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: CircleAvatar(child: Text(priceItem.priceListNo.toString())),
                  title: Text(
                    '${numberFormatter.format(priceItem.price)} ${priceItem.currencyCode}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text('Fiyat Liste No: ${priceItem.priceListNo}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}