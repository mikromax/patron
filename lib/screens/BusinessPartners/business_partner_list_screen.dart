import 'package:flutter/material.dart';
import '../../models/BusinessPartners/business_partner_dto.dart';
import '../../models/Helpers/paginated_result.dart';
import '../../models/Helpers/paginated_search_query.dart';
import '../../services/api/business_partner_api.dart';
// Şimdilik placeholder'lara yönlendireceğiz
import '../placeholders/generic_placeholder_screen.dart';
// Dosya ekleri ekranını daha sonra bağlayacağız (AttachmentScreen)

class BusinessPartnerListScreen extends StatefulWidget {
  const BusinessPartnerListScreen({super.key});

  @override
  State<BusinessPartnerListScreen> createState() => _BusinessPartnerListScreenState();
}

class _BusinessPartnerListScreenState extends State<BusinessPartnerListScreen> {
  final BusinessPartnerApi _api = BusinessPartnerApi();
  
  PaginatedResult<BusinessPartnerDto>? _result;
  bool _isLoading = false;
  // Pagination state
  final PaginatedSearchQuery _currentQuery = PaginatedSearchQuery(pageSize: 20);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; });
    try {
      final result = await _api.search(_currentQuery);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      setState(() { _isLoading = false; });
    }
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
      appBar: AppBar(title: const Text('İş Ortakları (BP)')),
      body: Column(
        children: [
          // YENİ BP BUTONU
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Yeni İş Ortağı (BP)'),
                onPressed: () {
                  // TODO: Aşama 2 (Yeni Kayıt Ekranı)
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericPlaceholderScreen(pageTitle: 'Yeni BP')));
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ),
          ),

          // LİSTE
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _result == null || _result!.data.isEmpty
                ? const Center(child: Text('Kayıt bulunamadı.'))
                : ListView.builder(
                    itemCount: _result!.data.length,
                    itemBuilder: (context, index) {
                      final bp = _result!.data[index];
                      return _buildBPCard(bp);
                    },
                  ),
          ),

          // SAYFALAMA
          if (_result != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.navigate_before), onPressed: _currentQuery.pageNumber > 1 ? _prevPage : null),
                  Text('Sayfa ${_result!.currentPage} / ${_result!.totalPages} (${_result!.totalCount} kayıt)'),
                  IconButton(icon: const Icon(Icons.navigate_next), onPressed: _currentQuery.pageNumber < _result!.totalPages ? _nextPage : null),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBPCard(BusinessPartnerDto bp) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(bp.isActive ? Icons.check_circle : Icons.cancel, color: bp.isActive ? Colors.green : Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(bp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32.0, bottom: 8.0),
              child: Text(bp.code, style: TextStyle(color: Colors.grey.shade700)),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Menü
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  tooltip: 'Menü',
                  onPressed: () { /* TODO: Ekstra menüler */ },
                ),
                // 2. Accounts (Hesaplar)
                IconButton(
                  icon: const Icon(Icons.account_tree, color: Colors.blue),
                  tooltip: 'Hesaplar (BPA)',
                  onPressed: () {
                    // TODO: Aşama 3 (BPA Listesi)
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GenericPlaceholderScreen(pageTitle: '${bp.title} - Hesaplar')));
                  },
                ),
                // 3. Detay (Düzenle)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Detay',
                  onPressed: () {
                    // TODO: Aşama 2 (Detay Ekranı)
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GenericPlaceholderScreen(pageTitle: '${bp.title} - Detay')));
                  },
                ),
                // 4. Attachments (Dosyalar)
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.indigo),
                  tooltip: 'Dosyalar',
                  onPressed: () {
                    // TODO: Aşama 5 (Dosya Ekleri)
                    // Buraya AttachmentScreen'i bağlayacağız
                    // EntityName="BusinessPartner", EntityId=bp.id
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