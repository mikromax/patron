import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/nakit_varliklar_model.dart';
import '../screens/syncfusion_pie_chart_screen.dart'; 
import '../screens/placeholders/detail_grid_screen.dart';
import '../screens/placeholders/generic_placeholder_screen.dart';
import '../screens/credit_debit_barchart_screen.dart';
import '../services/api/dashboard_api.dart';
import '../models/get_inventory_status_query.dart';
import '../models/inventory_status_dto.dart';
import '../models/account_credit_debit_status_dto.dart';
import '../models/get_account_credit_debit_status_query.dart';
import '../screens/placeholders/credit_debit_detail_screen.dart';
import '../screens/placeholders/inventory_detail_screen.dart';
import '../screens/inventory_grouped_barchart_screen.dart';
import '../models/bank_credits_vm.dart';
import '../models/get_bank_credits_query.dart';
import '../screens/placeholders/bank_credits_detail_screen.dart';
import '../screens/bank_credits_barchart_screen.dart';
import '../models/nonecash_assets_vm.dart';
import '../models/get_nonecash_assets_query.dart';
import '../screens/placeholders/nonecash_assets_detail_screen.dart';
import '../screens/nonecash_assets_barchart_screen.dart';
import '../services/api/inventory_api.dart';
// ... enum ve StatefulWidget tanımı aynı kalıyor ...
enum ScorecardState { loading, success, error }

class ScorecardWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? apiEndpoint;

  const ScorecardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.apiEndpoint,
  });

  @override
  State<ScorecardWidget> createState() => _ScorecardWidgetState();
}


class _ScorecardWidgetState extends State<ScorecardWidget> {
  // ... state değişkenleri ve _fetchData fonksiyonu aynı kalıyor ...
  ScorecardState _currentState = ScorecardState.loading;
  String _displayValue = '';
  String _errorMessage = '';
  final DashboardApi _apiService = DashboardApi();
  final InventoryApi _apiInventory = InventoryApi();
  NakitVarliklar? _data;
  List<AccountCreditDebitStatusDto>? _creditDebitData; 
  List<InventoryStatusDto>? _inventoryData;
  List<BankCreditsVM>? _bankCreditsData;
  List<NonecashAssetsVM>? _noneCashAssetsData;
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _currentState = ScorecardState.loading;
    });
    if (widget.apiEndpoint == null) {
      return; 
    }
    try {
      if (widget.apiEndpoint == 'nakit_varliklar') {
        final data = await _apiService.getCashAssets();
        final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
        setState(() {
          _data = data;
          _displayValue = formatter.format(data.totalAmountTl);
          _currentState = ScorecardState.success;
        });
      }
      else if (widget.apiEndpoint == 'borclar' || widget.apiEndpoint == 'alacaklar') {
        final isDebit = widget.apiEndpoint == 'borclar';
        final query = GetAccountCreditDebitStatusQuery(isDebit: isDebit);
        final data = await _apiService.getAccountCreditDebitStatus(query);
        final total = data.fold(0.0, (sum, item) => sum + item.amountTl);
        final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
        setState(() {
          _creditDebitData = data;
          _displayValue = formatter.format(total);
          _currentState = ScorecardState.success;
        });
      }
      else if (widget.apiEndpoint == 'stoklar') {
        final data = await _apiInventory.getInventoryStatus(GetInventoryStatusQuery());
        final total = data.fold(0.0, (sum, item) => sum + item.amountTl);
        final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
        setState(() { _inventoryData = data; _displayValue = formatter.format(total); _currentState = ScorecardState.success; });
      }
      else if (widget.apiEndpoint == 'krediler') {
      final data = await _apiService.getBankCredits(GetBankCreditsQuery());
      final total = data.fold(0.0, (sum, item) => sum + item.amountTl);
       final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
      setState(() { _bankCreditsData = data; _displayValue = formatter.format(total); _currentState = ScorecardState.success; });
    }
    else if (widget.apiEndpoint == 'degerli_kagitlar') {
      final data = await _apiService.getNoneCashAssets(GetNoneCashAssetsQuery());
      final total = data.fold(0.0, (sum, item) => sum + item.amount);
      final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
      setState(() { _noneCashAssetsData = data; _displayValue = formatter.format(total); _currentState = ScorecardState.success; });
    }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _currentState = ScorecardState.error;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      // ... Card yapısı ve üst kısımlar aynı kalıyor ...
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, size: 40, color: widget.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: _buildContent(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Detay Butonu (Aynı)
                IconButton(
                  icon: const Icon(Icons.grid_on, color: Colors.black54),
                  tooltip: 'Detay Grid',
                  onPressed: _currentState == ScorecardState.success 
                    ? () {
          if (widget.apiEndpoint == 'nakit_varliklar') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailGridScreen(pageTitle: '${widget.title} - Detaylar', details: _data!.details)));
          } else if (_creditDebitData != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreditDebitDetailScreen(pageTitle: '${widget.title} - Detaylar', details: _creditDebitData!)));
          } else if (_inventoryData != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryDetailScreen(pageTitle: '${widget.title} - Detaylar', details: _inventoryData!)));
          } else if (_bankCreditsData != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BankCreditsDetailScreen(pageTitle: '${widget.title} - Detaylar', details: _bankCreditsData!)));
      }
      else if (_noneCashAssetsData != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NonecashAssetsDetailScreen(pageTitle: '${widget.title} - Detaylar', details: _noneCashAssetsData!)));
      }
        }
      : null,
                ),
                // Grafik Butonu
                IconButton(
                  icon: const Icon(Icons.pie_chart, color: Colors.black54),
                  tooltip: 'Grafik',
                  onPressed: _currentState == ScorecardState.success
                    ? ()  {
                          // Hangi karttan basıldığını kontrol et ve doğru sayfayı aç
                          if (widget.apiEndpoint == 'nakit_varliklar' && _data != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SyncfusionPieChartScreen(details: _data!.details)));
                          } 
                          else if ((widget.apiEndpoint == 'borclar' || widget.apiEndpoint == 'alacaklar') && _creditDebitData != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CreditDebitBarChartScreen(pageTitle: widget.title, details: _creditDebitData!)));
                          }
                          else if (widget.apiEndpoint == 'stoklar' && _inventoryData != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryGroupedBarChartScreen(pageTitle: widget.title, details: _inventoryData!, groupBy: 'warehouse')));
                          }
                          else if (widget.apiEndpoint == 'krediler' && _bankCreditsData != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BankCreditsBarChartScreen(pageTitle: widget.title, details: _bankCreditsData!)));
      }
      else if (widget.apiEndpoint == 'degerli_kagitlar' && _noneCashAssetsData != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NonecashAssetsBarChartScreen(pageTitle: '${widget.title} (Tipe Göre)', details: _noneCashAssetsData!, groupBy: 'doctype')));
      }
                        }
                      : null,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black54),
                  tooltip: 'Diğer Seçenekler',
                  enabled: _currentState == ScorecardState.success,
                  onSelected: (value) {
                    if (value == 'refresh') {
                      _fetchData();
                    } else if (value.startsWith('stok_grup_')) {
                      final groupBy = value.split('_').last; // 'itemGroup' veya 'brand'
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryGroupedBarChartScreen(pageTitle: widget.title, details: _inventoryData!, groupBy: groupBy)));
                    }else if (value == 'dk_pos_graph') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NonecashAssetsBarChartScreen(pageTitle: '${widget.title} (Pozisyona Göre)', details: _noneCashAssetsData!, groupBy: 'position')));
      } else {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => GenericPlaceholderScreen(pageTitle: '${widget.title} - $value'),
                      ));
                    }
                  },
                  itemBuilder: (context) {
                    // Endpoint'e göre farklı menüler göster
                    if (widget.apiEndpoint == 'stoklar') {
                      return [
                        const PopupMenuItem(value: 'refresh', child: Text('Yenile')),
                        const PopupMenuItem(value: 'stok_grup_itemGroup', child: Text('Gruba Göre Grafik')),
                        const PopupMenuItem(value: 'stok_grup_brand', child: Text('Markaya Göre Grafik')),
                      ];
                    } else if (widget.apiEndpoint == 'degerli_kagitlar') {
        return [
          const PopupMenuItem(value: 'refresh', child: Text('Yenile')),
          const PopupMenuItem(value: 'dk_pos_graph', child: Text('Pozisyona Göre Grafik')),
        ];
      }
                    // Varsayılan menü
                    return [
                      const PopupMenuItem(value: 'refresh', child: Text('Yenile')),
                     
                     
                    ];
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // _buildContent fonksiyonu aynı kalıyor...
   Widget _buildContent() {
    switch (_currentState) {
      case ScorecardState.loading:
        return const CircularProgressIndicator();
      case ScorecardState.success:
        return Text(_displayValue, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold));
      case ScorecardState.error:
        return Tooltip(
          message: _errorMessage,
          child: IconButton(
            icon: const Icon(Icons.error_outline, color: Colors.red, size: 30),
            onPressed: _fetchData, 
          ),
        );
    }
  }
}