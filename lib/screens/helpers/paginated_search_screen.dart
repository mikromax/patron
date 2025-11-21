import 'package:flutter/material.dart';
import '../../models/Helpers/BaseModuleExport.dart';
// Föy'ü çağırmak için gerekli import'lar
import '../../models/nakit_varliklar_model.dart';
import '../placeholders/statement_page_screen.dart';

// Bu ekran, arama yapmak için bir fonksiyonu parametre olarak alır

class PaginatedSearchScreen extends StatefulWidget {
  final String title;
  final PaginatedSearchFunction onSearch;
  final SearchType searchType; // YENİ PARAMETRE

  const PaginatedSearchScreen({
    super.key, 
    required this.title, 
    required this.onSearch,
    required this.searchType, // Artık zorunlu
  });

  @override
  State<PaginatedSearchScreen> createState() => _PaginatedSearchScreenState();
}

class _PaginatedSearchScreenState extends State<PaginatedSearchScreen> {
  PaginatedResult<BaseCardViewModel>? _result;
  bool _isLoading = false;

  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Sorgu nesnesini state'te tutmak daha yönetilebilirdir
  final PaginatedSearchQuery _currentQuery = PaginatedSearchQuery();

  @override
  void initState() {
    super.initState();
    _fetchData(); // Ekran açılır açılmaz ilk 20 kaydı getir
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; });
    try {
      final result = await widget.onSearch(_currentQuery);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
      setState(() { _isLoading = false; });
    }
  }

  void _onFilter() {
    setState(() {
      _currentQuery.pageNumber = 1; // Yeni filtreleme, 1. sayfadan başlamalı
      _currentQuery.codeFilter = _codeController.text;
      _currentQuery.descriptionFilter = _descriptionController.text;
    });
    _fetchData();
  }
  void _nextPage() {
    if (_result != null && _currentQuery.pageNumber < _result!.totalPages) {
      setState(() => _currentQuery.pageNumber++);
      _fetchData();
    }
  }
  void _prevPage() {
    if (_currentQuery.pageNumber > 1) {
      setState(() => _currentQuery.pageNumber--);
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          _buildFilterPanel(),
          const Divider(height: 1),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: _result == null
                ? const Center(child: Text('Veri yükleniyor...'))
                : _result!.data.isEmpty
                    ? const Center(child: Text('Sonuç bulunamadı.'))
                    : ListView.builder(
                        itemCount: _result!.data.length,
                        itemBuilder: (context, index) {
                          final item = _result!.data[index];
                          return ListTile(
                            title: Text(item.description),
                            subtitle: Text(item.code),
                            onTap: () => Navigator.pop(context, item),
                            // YENİ BÖLÜM: "Sağ Klik" Menüsü
                            trailing: _buildPopupMenu(context, item),
                          );
                        },
                      ),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'Kod Filtresi'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Açıklama Filtresi'))),
          IconButton(icon: const Icon(Icons.search), onPressed: _onFilter),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_result == null || _result!.totalCount == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.first_page), onPressed: _currentQuery.pageNumber > 1 ? () { setState(() => _currentQuery.pageNumber = 1); _fetchData(); } : null),
          IconButton(icon: const Icon(Icons.navigate_before), onPressed: _currentQuery.pageNumber > 1 ? _prevPage : null),
          Text('Sayfa ${_result!.currentPage} / ${_result!.totalPages} (${_result!.totalCount} kayıt)'),
          IconButton(icon: const Icon(Icons.navigate_next), onPressed: _currentQuery.pageNumber < _result!.totalPages ? _nextPage : null),
          IconButton(icon: const Icon(Icons.last_page), onPressed: _currentQuery.pageNumber < _result!.totalPages ? () { setState(() => _currentQuery.pageNumber = _result!.totalPages); _fetchData(); } : null),
        ],
      ),
    );
  }

  // "Sağ klik" menüsünü oluşturan fonksiyon
  Widget? _buildPopupMenu(BuildContext context, BaseCardViewModel item) {
    // Sadece Müşteri ararken bu menüyü göster
    if (widget.searchType == SearchType.customer) {
      return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'foy') {
            _navigateToStatement(context, item);
          }
          // TODO: "Bakiye Yaşlandırma", "Siparişler" vb. eklenecek
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'foy', child: Text('Föy')),
          // ... ileride eklenecek diğer menü öğeleri ...
        ],
      );
    }
    // Plasiyer veya 'other' aramasında menü gösterme
    return null;
  }

  void _navigateToStatement(BuildContext context, BaseCardViewModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatementPageScreen(
          // Föy ekranı 'Detail' beklediği için 'BaseCardViewModel'i dönüştürüyoruz
          detail: Detail(code: item.code, definition: item.description, currency: '', amountOriginal: 0, amountTl: 0),
          context: StatementContext.customer,
        ),
      ),
    );
  }
}

