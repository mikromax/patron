import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/account_types.dart';
import '../../models/cash_group_type.dart';
import '../../models/get_customer_account_groups_query.dart';
import '../../models/item_transaction_dto.dart';
import '../../models/nakit_varliklar_model.dart';
import '../../services/api/finance_api.dart';

// Föy sayfasının nereden çağrıldığını belirtmek için bir context
enum StatementContext { cash, customer }
final FinanceApi _apiService = FinanceApi();
// API çağrılarının durumunu yönetmek için
enum PageState { idle, loadingParams, loadingData, success, error }

class StatementPageScreen extends StatefulWidget {
  final Detail detail;
  final StatementContext context;
  
  const StatementPageScreen({super.key, required this.detail, required this.context});

  @override
  State<StatementPageScreen> createState() => _StatementPageScreenState();
}

class _StatementPageScreenState extends State<StatementPageScreen> {
  bool _isPanelExpanded = true;
  late DateTime _startDate, _endDate;
  
  // Form state
  AccountTypes? _accountType; // Tespit edilen veya sabit atanan
  int? _selectedGroupId; // Seçilen grubun ID'si (int)
  List<DropdownMenuItem<int>> _groupOptions = []; // Lookup içeriği
  
  // API state
  PageState _pageState = PageState.loadingParams;
  String _errorMessage = '';
  List<ItemTransactionDto>? _statementData;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 7));
    _initializeParams();
  }

  Future<void> _initializeParams() async {
    try {
      if (widget.context == StatementContext.customer) {
        // Borç/Alacak akışı
        _accountType = AccountTypes.Carimiz; // Her zaman 0
        final groups = await _apiService.getCustomerAccountGroups(GetCustomerAccountGroupsQuery(customerCode: widget.detail.code));
        setState(() {
          _groupOptions = groups.map((g) => DropdownMenuItem(value: g.groupNo, child: Text(g.currencySymbol))).toList();
          if (_groupOptions.isNotEmpty) _selectedGroupId = _groupOptions.first.value;
          _pageState = PageState.idle;
        });
      } else {
        // Nakit Varlıklar akışı
        _accountType = await _apiService.detectAccountType(widget.detail.code);
        setState(() {
          _groupOptions = CashGroupType.values.map((g) => DropdownMenuItem(value: g.value, child: Text(g.aStext))).toList();
          _selectedGroupId = CashGroupType.Mevduat.value; // Varsayılan Mevduat
          _pageState = PageState.idle;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _pageState = PageState.error;
      });
    }
  }

  Future<void> _fetchStatement() async {
    if (_accountType == null || _selectedGroupId == null) return;

    setState(() { _pageState = PageState.loadingData; _isPanelExpanded = false; });

    try {
      final data = await _apiService.getAccountTransactionStatement(
        accountType: _accountType!,
        accountCode: widget.detail.code,
        groupId: _selectedGroupId!,
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _statementData = data;
        _pageState = PageState.success;
        if (data.isEmpty) _isPanelExpanded = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _pageState = PageState.error;
        _isPanelExpanded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.detail.definition} - Föy'), backgroundColor: Colors.indigo),
      body: Column(
        children: [
          _buildCollapsiblePanel(),
          Expanded(child: _buildResultArea()),
        ],
      ),
    );
  }

  Widget _buildCollapsiblePanel() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isPanelExpanded ? _buildExpandedPanel() : _buildCollapsedPanelHeader(),
      transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
    );
  }

  Widget _buildCollapsedPanelHeader() {
    return InkWell(
      onTap: () => setState(() => _isPanelExpanded = true),
      child: Container(key: const ValueKey('collapsed'), padding: const EdgeInsets.all(12), color: Colors.grey[200], child: const Row(children: [Text('Filtreleri Göster', style: TextStyle(fontWeight: FontWeight.bold)), Spacer(), Icon(Icons.arrow_drop_down)])),
    );
  }

  Widget _buildExpandedPanel() {
    return Container(
      key: const ValueKey('expanded'),
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: _pageState == PageState.loadingParams
          ? const Center(child: CircularProgressIndicator())
          : _pageState == PageState.error
              ? Center(child: Text('Parametreler yüklenemedi: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker('Başlangıç Tarihi', _startDate, (date) => setState(() => _startDate = date))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDatePicker('Bitiş Tarihi', _endDate, (date) => setState(() => _endDate = date))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedGroupId,
                      decoration: const InputDecoration(labelText: 'Grup', border: OutlineInputBorder()),
                      items: _groupOptions,
                      onChanged: (value) => setState(() => _selectedGroupId = value),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _fetchStatement, child: const Text('Devam'))),
                  ],
                ),
    );
  }

 Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onDateSelected) {
    final DateFormat formatter = DateFormat('dd.MM.yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context, 
              initialDate: date, 
              firstDate: DateTime(2000), 
              lastDate: DateTime(2101) // Gelecekte bir tarih
            );
            if (picked != null && picked != date) onDateSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatter.format(date)),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // SONUÇ ALANI ARTIK ITEMTRANSACTIONDTO GÖSTERİYOR
  Widget _buildResultArea() {
    switch (_pageState) {
      case PageState.idle:
      case PageState.loadingParams:
        return const Center(child: Text('Lütfen yukarıdan filtreleri seçip "Devam" butonuna basın.'));
      case PageState.loadingData:
        return const Center(child: CircularProgressIndicator());
      case PageState.error:
        return const Center(child: Text(''));
      case PageState.success:
        if (_statementData == null || _statementData!.isEmpty) {
          return const Center(child: Text('Seçilen kriterlere uygun veri bulunamadı.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _statementData!.length,
          itemBuilder: (context, index) => _buildTransactionCard(_statementData![index]),
        );
    }
  }

  // "Stok Föyü" için tasarladığımız kartı buraya taşıyoruz
  Widget _buildTransactionCard(ItemTransactionDto transaction) {
    final dateFormatter = DateFormat('dd.MM.yyyy');
    final isEntry = transaction.quantity >= 0;
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
          '${transaction.quantity} ${transaction.unit}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isEntry ? Colors.green : Colors.red),
        ),
      ),
    );
  }
}