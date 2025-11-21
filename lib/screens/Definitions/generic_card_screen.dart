import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
// Modeller
import '../../models/Helpers/base_card_view_model.dart';
import '../../models/helpers/paginated_result.dart';
import '../../models/helpers/paginated_search_query.dart';
// Servis
import '../../services/api/generic_card_api.dart';
// Diğer Ekranlar
import '../Attachments/attachment_screen.dart';
import '../placeholders/generic_placeholder_screen.dart';

class GenericCardScreen extends StatefulWidget {
  final String pageTitle;
  final String apiEndpoint; // Örn: "api/regions"
  final String entityName;  // Dosya ekleri için Entity adı (Örn: "Region")

  const GenericCardScreen({
    super.key,
    required this.pageTitle,
    required this.apiEndpoint,
    required this.entityName,
  });

  @override
  State<GenericCardScreen> createState() => _GenericCardScreenState();
}

class _GenericCardScreenState extends State<GenericCardScreen> {
  late GenericCardApi _api;
  
  PaginatedResult<BaseCardViewModel>? _result;
  bool _isLoading = false;
  
  
  // Pagination & Filter
  final PaginatedSearchQuery _currentQuery = PaginatedSearchQuery(pageSize: 20);
  final _codeFilterController = TextEditingController();
  final _descFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Servisi, gelen endpoint ile başlatıyoruz (Dependency Injection benzeri)
    _api = GenericCardApi(widget.apiEndpoint);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; });
    try {
      _currentQuery.codeFilter = _codeFilterController.text;
      _currentQuery.descriptionFilter = _descFilterController.text;
      
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

  void _onPageChanged(int newPage) {
    _currentQuery.pageNumber = newPage;
    _fetchData();
  }

  // --- EKLE / DÜZENLE POPUP ---
  Future<void> _showEditDialog({BaseCardViewModel? existingItem}) async {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: existingItem?.code ?? '');
    final descController = TextEditingController(text: existingItem?.description ?? '');
    bool isPassive = existingItem?.isPassive ?? false;
    bool isSubmitting = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingItem == null ? 'Yeni Kayıt' : 'Düzenle'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Kod'),
                  validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                  // Genellikle kodlar update edilirken değiştirilmez, dilerseniz readOnly yapabilirsiniz
                  // readOnly: existingItem != null, 
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                  validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                ),
                SwitchListTile(
                  title: const Text('Pasif'),
                  value: isPassive,
                  onChanged: (v) => setDialogState(() => isPassive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('İptal')),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() => isSubmitting = true);
                  try {
                    final dto = BaseCardViewModel(
                      id: existingItem?.id ?? const Uuid().v4(),
                      code: codeController.text,
                      description: descController.text,
                      isPassive: isPassive,
                    );

                    if (existingItem == null) {
                      await _api.create(dto);
                    } else {
                      await _api.update(dto);
                    }

                    if (mounted) {
                      Navigator.pop(dialogContext);
                      _fetchData(); // Listeyi yenile
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İşlem Başarılı'), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                     setDialogState(() => isSubmitting = false);
                     // Hata mesajını ana context'te göster
                     if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  // --- SİLME ---
  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sil?'),
        content: const Text('Bu kayıt silinecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hayır')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.delete(id);
        _fetchData();
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silindi'), backgroundColor: Colors.green));
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pageTitle)),
      // --- YENİ BUTONU (SAĞ ALT) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // --- FİLTRE ALANI ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _codeFilterController, decoration: const InputDecoration(labelText: 'Kod Ara', prefixIcon: Icon(Icons.search)))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _descFilterController, decoration: const InputDecoration(labelText: 'Açıklama Ara'))),
                IconButton(icon: const Icon(Icons.filter_list), onPressed: () { _currentQuery.pageNumber = 1; _fetchData(); }),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- LİSTE ---
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _result == null || _result!.data.isEmpty
                  ? const Center(child: Text('Kayıt bulunamadı.'))
                  : ListView.builder(
                      itemCount: _result!.data.length,
                      itemBuilder: (context, index) {
                        final item = _result!.data[index];
                        return _buildCard(item);
                      },
                    ),
          ),

          // --- SAYFALAMA ---
          if (_result != null)
             Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.navigate_before), onPressed: _result!.currentPage > 1 ? () => _onPageChanged(_result!.currentPage - 1) : null),
                  Text('Sayfa ${_result!.currentPage} / ${_result!.totalPages} (${_result!.totalCount})'),
                  IconButton(icon: const Icon(Icons.navigate_next), onPressed: _result!.currentPage < _result!.totalPages ? () => _onPageChanged(_result!.currentPage + 1) : null),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BaseCardViewModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.isPassive ? Icons.visibility_off : Icons.check_circle, color: item.isPassive ? Colors.grey : Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
            Text(item.code, style: TextStyle(color: Colors.grey.shade700)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), tooltip: 'Düzenle', onPressed: () => _showEditDialog(existingItem: item)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Sil', onPressed: () => _deleteItem(item.id)),
                // DOSYA EKLERİ (GENERIC)
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.indigo), 
                  tooltip: 'Dosyalar', 
                  onPressed: () {
                     Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AttachmentScreen(
                        entityName: widget.entityName, // Dinamik Entity Adı
                        entityId: item.id,
                      )
                    ));
                  }
                ),
                // KULLANICI TANIMLI ALANLAR (Placeholder)
                IconButton(
                  icon: const Icon(Icons.note_alt_outlined, color: Colors.orange), 
                  tooltip: 'Özel Alanlar', 
                  onPressed: () {
                     Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const GenericPlaceholderScreen(pageTitle: 'Kullanıcı Tanımlı Alanlar')
                    ));
                  }
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}