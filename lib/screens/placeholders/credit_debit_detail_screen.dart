import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/account_credit_debit_status_dto.dart';
import '../../models/nakit_varliklar_model.dart';
import 'generic_placeholder_screen.dart';
import 'statement_page_screen.dart';
import '../customer_orders_screen.dart';
import '../balance_aging_screen.dart';
class CreditDebitDetailScreen extends StatelessWidget {
  final String pageTitle;
  final List<AccountCreditDebitStatusDto> details;

  const CreditDebitDetailScreen({super.key, required this.pageTitle, required this.details});

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

  Widget _buildDetailCard(BuildContext context, AccountCreditDebitStatusDto detail) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır Bilgileri
            Text('${detail.code} - ${detail.definition}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Temsilci: ${detail.representative} | Sektör: ${detail.sector}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const Divider(height: 16),
            // Tutar Bilgisi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Toplam Tutar (TL)', style: TextStyle(color: Colors.grey)),
                Text(currencyFormatter.format(detail.amountTl), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            
            // --- DEĞİŞİKLİK: BUTONLAR IKON OLARAK YENİDEN TASARLANDI ---
            // Butonları sağa hizalamak için Row kullanıyoruz.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'Yaşlandırma Tablosu',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BalanceAgingScreen(
                          accountCode: detail.code,
                          accountName: detail.definition,
                        ),
                      ),
                    );
                  },
                ),
                
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  tooltip: 'Siparişler',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => CustomerOrdersScreen(
                      accountCode: detail.code,
                      accountName: detail.definition,
                     ),
                    ),
                   );
                 },
                ),
                IconButton(
                  icon: const Icon(Icons.shield_outlined),
                  tooltip: 'Risk Özeti',
                  onPressed: () => _navigateToPlaceholder(context, 'Risk Özeti'),
                ),
                // Föy butonu için daha anlamlı bir ikon
                IconButton(
                  icon: const Icon(Icons.list_alt),
                  tooltip: 'Föy',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatementPageScreen(
                          detail: Detail(code: detail.code, definition: detail.definition, currency: detail.currency, amountOriginal: detail.amountOriginal, amountTl: detail.amountTl),
                          preselectedGroup: LookupItem(detail.grup, detail.currency),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _navigateToPlaceholder(BuildContext context, String title) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => GenericPlaceholderScreen(pageTitle: title)));
  }
}