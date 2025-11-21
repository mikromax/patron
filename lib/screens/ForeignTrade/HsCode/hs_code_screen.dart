import 'package:flutter/material.dart';
import 'package:patron/models/ForeignTrade/HsCode/hs_code_detail_dto.dart';
import 'package:patron/models/Helpers/paginated_result.dart';
import 'package:patron/models/Helpers/paginated_search_query.dart';
import 'package:patron/services/api/ForeignTrade/hscode_api.dart';
import '../../Attachments/attachment_screen.dart'; // Dosya Ekleri için
import 'reference_price_list_screen.dart';
class HsCodeScreen extends StatefulWidget {
  const HsCodeScreen({super.key});

  @override
  State<HsCodeScreen> createState() => _HsCodeScreenState();
}

class _HsCodeScreenState extends State<HsCodeScreen> {
  final HsCodeApi _api = HsCodeApi();
  PaginatedResult<HsCodeDetailDto>? _result;
  bool _isLoading = false;

  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final PaginatedSearchQuery _currentQuery = PaginatedSearchQuery(pageSize: 20);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; });
    try {
      final query = PaginatedSearchQuery(
        pageNumber: _currentQuery.pageNumber,
        codeFilter: _codeController.text,
        descriptionFilter: _descriptionController.text,
      );
      final result = await _api.searchHsCodes(query);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      setState(() { _isLoading = false; });
    }
  }

  void _onFilter() {
    setState(() => _currentQuery.pageNumber = 1);
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
      appBar: AppBar(title: const Text('GTİP (HsCode) Listesi')),
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
                          return _buildHsCodeCard(item);
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
          Expanded(child: TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'GTİP Kodu Filtresi'))),
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

  // Yeni Kart Tasarımı
  Widget _buildHsCodeCard(HsCodeDetailDto item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(item.code, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text('Fasıl: ${item.phaseName} (${item.phaseCode})'),
            Text('Pozisyon: ${item.positionName} (${item.positionCode})'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.attach_file_outlined),
                  label: const Text('Dosyalar'),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AttachmentScreen(
                        entityName: 'HsCodes', // API'nin beklediği Entity Adı
                        entityId: item.id,
                      )
                    ));
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.price_change_outlined),
                  label: const Text('Ref. Fiyatlar'),
                  onPressed: () {
                    // TODO: Aşama 2 (ReferencePriceListScreen)
                     Navigator.push(context, MaterialPageRoute(
              builder: (context) => ReferencePriceListScreen(
                hsCodeId: item.id, // Seçilen kaydın ID'sini gönder
                hsCodeDescription: item.code, // Başlıkta kodu göster
              )
            ));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}