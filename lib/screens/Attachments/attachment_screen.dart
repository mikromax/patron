import 'package:flutter/material.dart';
import '../../models/Attachments/required_document_dto.dart';
import 'dart:io';
import '../../services/api/attachment_api.dart';
import '../../utils/file_picker_helper.dart';
// File işlemleri için
// Uint8List için
import 'package:open_filex/open_filex.dart'; // Dosya açmak için
import 'package:path_provider/path_provider.dart'; // Geçici klasör için
import '../../models/Attachments/attachment_summary_dto.dart'; // Yeni modelimiz
import '../../services/api/settings_api.dart';
class AttachmentScreen extends StatefulWidget {
  final String entityName; // "CreditLimitRequest"
  final String entityId;   // Kaydedilmiş talebin Guid'i

  const AttachmentScreen({
    super.key, 
    required this.entityName, 
    required this.entityId,
  });

  @override
  State<AttachmentScreen> createState() => _AttachmentScreenState();
}

class _AttachmentScreenState extends State<AttachmentScreen> {
  final AttachmentApi _apiService = AttachmentApi();
  late Future<List<RequiredDocumentDto>> _rulesFuture;
  final SettingsApi _apisettins = SettingsApi();
  @override
  void initState() {
    super.initState();
    _rulesFuture = _loadRules();
  }

  Future<List<RequiredDocumentDto>> _loadRules() {
    // API'yi yeni imza ile çağır
    return _apisettins.getDocumentTypeRules(widget.entityName, widget.entityId);
  }

 // GÜNCELLENMİŞ METOT: Dosyaları Göster/Yönet
  void _onShowAttachedFiles(RequiredDocumentDto rule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tam ekran yüksekliği kullanabilsin
      builder: (BuildContext context) {
        // Panel içindeki state'i (yükleniyor, liste güncelleme) yönetmek için
        return _AttachedFilesPanel(
          apiService: _apiService,
          rule: rule,
          entityName: widget.entityName,
          entityId: widget.entityId,
          // Panel kapandığında ana ekranı yenilemek için callback
          onFilesChanged: () {
            setState(() {
              _rulesFuture = _loadRules();
            });
          },
        );
      },
    );
  }

 void _onAddNewFile(RequiredDocumentDto rule) {
    FilePickerHelper.showSelectionSheet(context, (File file) async {
      // Dosya seçildi, şimdi yükleyelim
      _uploadFile(rule, file);
    });
  }

  Future<void> _uploadFile(RequiredDocumentDto rule, File file) async {
    // Kullanıcıya yükleniyor olduğunu gösterelim (örneğin basit bir loading dialog)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _apiService.uploadAttachment(
        entityId: widget.entityId,
        entityName: widget.entityName,
        documentTypeId: rule.documentTypeId,
        file: file,
      );

      if (mounted) {
        Navigator.pop(context); // Loading'i kapat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosya başarıyla yüklendi!'), backgroundColor: Colors.green),
        );
        // Listeyi yenile ki sayaç artsın
        setState(() {
          _rulesFuture = _loadRules();
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Loading'i kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dosya Ekleri')),
      body: FutureBuilder<List<RequiredDocumentDto>>(
        future: _rulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Bu evrak için dosya kuralı bulunamadı.'));
          }
          
          final rules = snapshot.data!;
          // Gelen veriyi (kuralları) CardView şeklinde listeliyoruz
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index];
              return _buildRuleCard(rule);
            },
          );
        },
      ),
    );
  }

  // İstediğiniz CardView'i oluşturan widget
  Widget _buildRuleCard(RequiredDocumentDto rule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kural Adı ve Zorunluluk Durumu
            Row(
              children: [
                Icon(
                  rule.isMandatory ? Icons.error : Icons.info_outline,
                  color: rule.isMandatory ? Colors.red : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rule.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                // Yeni Eklenen Dosya Sayacı
                Chip(
                  label: Text('${rule.attachmentsCount} Dosya'),
                  backgroundColor: rule.attachmentsCount > 0 ? Colors.green.shade100 : Colors.grey.shade200,
                ),
              ],
            ),
            const Divider(height: 16),
            // İki ana buton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Göster/Yönet'),
                  // Hiç dosya yoksa bu butonu pasif yap
                  onPressed: rule.attachmentsCount > 0 ? () => _onShowAttachedFiles(rule) : null,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Yeni Dosya Ekle'),
                  onPressed: () => _onAddNewFile(rule),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
}
// --- YARDIMCI WIDGET: DOSYA YÖNETİM PANELİ ---
class _AttachedFilesPanel extends StatefulWidget {
  final AttachmentApi apiService;
  final RequiredDocumentDto rule;
  final String entityName;
  final String entityId;
  final VoidCallback onFilesChanged;

  const _AttachedFilesPanel({
    required this.apiService,
    required this.rule,
    required this.entityName,
    required this.entityId,
    required this.onFilesChanged,
  });

  @override
  State<_AttachedFilesPanel> createState() => _AttachedFilesPanelState();
}

class _AttachedFilesPanelState extends State<_AttachedFilesPanel> {
  late Future<List<AttachmentSummaryDto>> _filesFuture;
  bool _isProcessing = false; // Silme veya indirme sırasında UI'ı kilitlemek için

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _loadFiles() {
    setState(() {
      _filesFuture = widget.apiService.getAttachmentsList(
        widget.entityName, 
        widget.entityId, 
        widget.rule.documentTypeId
      );
    });
  }

  // Dosya Silme İşlemi
  Future<void> _deleteFile(String attachmentId) async {
    setState(() => _isProcessing = true);
    try {
      await widget.apiService.deleteAttachment(attachmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dosya silindi.'), backgroundColor: Colors.green));
        _loadFiles(); // Listeyi yenile
        widget.onFilesChanged(); // Ana ekrandaki sayacı güncelle
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Dosya İndirme ve Açma İşlemi
  Future<void> _openFile(AttachmentSummaryDto fileDto) async {
    setState(() => _isProcessing = true);
    try {
      // 1. Dosyayı indir
      final result = await widget.apiService.downloadAttachment(fileDto.id, fileDto.fileName);
      
      // 2. Geçici klasöre kaydet
      final tempDir = await getTemporaryDirectory();
      
      final tempFile = File('${tempDir.path}/${result.fileName}');
      await tempFile.writeAsBytes(result.bytes);

      // 3. Uygun uygulama ile aç
      final openResult = await OpenFilex.open(tempFile.path);
      if (openResult.type != ResultType.done) {
        throw Exception(openResult.message);
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dosya açılamadı: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // Ekranın %60'ı
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text("${widget.rule.displayName} - Dosyalar", style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          if (_isProcessing) const LinearProgressIndicator(),
          Expanded(
            child: FutureBuilder<List<AttachmentSummaryDto>>(
              future: _filesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Hata: ${snapshot.error}'));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Bu kural için dosya yok.'));

                final files = snapshot.data!;
                return ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file, color: Colors.indigo),
                        title: Text(file.fileName),
                        subtitle: Text(file.formattedSize),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_new, color: Colors.blue),
                              tooltip: 'Aç',
                              onPressed: _isProcessing ? null : () => _openFile(file),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Sil',
                              onPressed: _isProcessing ? null : () => _deleteFile(file.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}