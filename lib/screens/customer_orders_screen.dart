import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/get_all_orders_by_customer_query.dart';
import '../models/orders_by_customer_vm.dart';
import '../services/api_service.dart';
import 'approve_order_screen.dart';
import 'cancel_order_screen.dart';
import '../models/get_all_orders_by_item_query.dart';

// Ekranın hangi modda çalışacağını belirtmek için bir enum
enum OrderSearchMode { byCustomer, byItem }

class CustomerOrdersScreen extends StatefulWidget {
  final String code;
  final String name;
  final OrderSearchMode searchMode;

  const CustomerOrdersScreen({
    super.key, 
    required this.code, 
    required this.name,
    required this.searchMode,
  });

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  final ApiService _apiService = ApiService();
  
  // State yönetimi için değişkenler
  late Future<List<OrdersByCustomerVM>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    // Ekran ilk açıldığında veri çekme işlemini başlat
    _ordersFuture = _fetchOrders();
  }

  // API'den veri çeken fonksiyon
 Future<List<OrdersByCustomerVM>> _fetchOrders() {
    // Arama moduna göre doğru API metodunu çağır
    if (widget.searchMode == OrderSearchMode.byCustomer) {
      return _apiService.searchOrdersByCustomer(GetAllOrdersByCustomerQuery(accountCode: widget.code));
    } else { // byItem
      return _apiService.searchOrdersByItem(GetAllOrdersByItemQuery(itemCode: widget.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.name} - Siparişler')),
      body: FutureBuilder<List<OrdersByCustomerVM>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          // Yükleniyor durumu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Hata durumu
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hata: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(() { _ordersFuture = _fetchOrders(); }),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }
          // Başarılı ama veri yok durumu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text(' bekleyen sipariş bulunamadı.'));
          }

          // Başarılı ve veri var durumu
          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(context, orders[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrdersByCustomerVM order) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final numberFormatter = NumberFormat("#,##0.00", "tr_TR");
    final dateFormatter = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: Tarih ve Sipariş Tipi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateFormatter.format(order.orderDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                Chip(
                  // Artık doğrudan yeni getter'ımızı kullanıyoruz
                  label: Text(order.orderTypeText, style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Tipe göre farklı renkler vererek görsel ayrım sağlıyoruz
                  backgroundColor: order.orderType == 0 ? Colors.blue.shade100 : Colors.orange.shade100,
                  side: BorderSide.none,
                ),
              ],
            ),
            const Divider(height: 16),
            // Orta Bölüm: Stok Bilgileri
            Text('${order.code} - ${order.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Miktar: ${order.quantity} ${order.unit}'),
                Text(
                  '${numberFormatter.format(order.amount)} ${order.currency}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 16),
            // Alt Bölüm: Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CancelOrderScreen(order: order),
                    ));
                  },
                  child: const Text('Siparişi Kapat'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  // Koşullu 'onPressed': Eğer sipariş onaylıysa (isApproved == true),
                  // onPressed 'null' olur ve buton pasif hale gelir.
                  onPressed: order.isApproved ? null : () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ApproveOrderScreen(order: order),
                    ));
                  },

                  child: const Text('Onayla'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}