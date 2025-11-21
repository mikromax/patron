import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:uuid/uuid.dart';
import '../../models/Attachments/entity_type_dto.dart';
import '../../models/Attachments/required_document_dto.dart';
import '../../models/Attachments/document_type_rule_dto.dart';
import '../../services/api/attachment_api.dart';
import '../../services/api/settings_api.dart';
class FileDefinitionScreen extends StatefulWidget {
  const FileDefinitionScreen({super.key});

  @override
  State<FileDefinitionScreen> createState() => _FileDefinitionScreenState();
}

class _FileDefinitionScreenState extends State<FileDefinitionScreen> {
  final AttachmentApi _apiService = AttachmentApi();
  final Uuid _uuid = const Uuid();
  final SettingsApi _apisettings = SettingsApi();
  bool _isLoadingEntities = true;
  List<EntityTypeDto> _entities = [];
  EntityTypeDto? _selectedEntity;

  bool _isLoadingDefinitions = false;
  List<RequiredDocumentDto> _definitions = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadEntities();
  }

  Future<void> _loadEntities() async {
    try {
      final entities = await _apisettings.getAttachableEntityTypes();
      setState(() {
        _entities = entities..sort((a,b) => a.display.compareTo(b.display));
        _isLoadingEntities = false;
      });
    } catch (e) {
      _showError('Entity listesi yüklenemedi: $e');
      setState(() { _isLoadingEntities = false; });
    }
  }

  Future<void> _onEntityChanged(EntityTypeDto? entity) async {
    if (entity == null) {
      setState(() { _selectedEntity = null; _definitions = []; });
      return;
    }
    setState(() { 
      _selectedEntity = entity; 
      _isLoadingDefinitions = true; 
      _definitions = [];
    });

    try {
      final definitions = await _apisettings.getDocumentTypeRules(entity.entityName,'00000000-0000-0000-0000-000000000000');
      setState(() {
        _definitions = definitions;
        _isLoadingDefinitions = false;
      });
    } catch(e) {
      _showError('Tanımlar yüklenemedi: $e');
      setState(() { _isLoadingDefinitions = false; });
    }
  }

  // --- HATA VE BAŞARI MESAJLARI İÇİN YENİ YARDIMCILAR ---
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  // --- "EKLE" VE "DÜZENLE" İÇİN ORTAK DİYALOG FONKSİYONU ---
  Future<void> _showRuleDialog({RequiredDocumentDto? existingRule}) async {
    final bool isEditing = existingRule != null;
    final formKey = GlobalKey<FormState>();
    
    // Form alanlarını, düzenleme ise dolu, ekleme ise boş başlat
    final docIdController = TextEditingController(text: existingRule?.documentTypeId ?? '');
    final displayNameController = TextEditingController(text: existingRule?.displayName ?? '');
    bool isMandatory = existingRule?.isMandatory ?? false;
    bool isPassive = existingRule?.isPassive ?? false;

    final result = await showDialog<RequiredDocumentDto>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Kuralı Düzenle' : 'Yeni Kural Ekle'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: docIdController,
                        // Düzenleme modunda DocumentTypeId (Anahtar) değiştirilemez
                        readOnly: isEditing,
                        decoration: InputDecoration(
                          labelText: 'Doküman Tipi ID (örn: BILANCO)',
                          filled: isEditing,
                          fillColor: isEditing ? Colors.grey[200] : null,
                        ),
                        validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                      ),
                      TextFormField(
                        controller: displayNameController,
                        decoration: const InputDecoration(labelText: 'Görünüm Adı (örn: Bilanço)'),
                        validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                      ),
                      SwitchListTile(
                        title: const Text('Zorunlu'),
                        value: isMandatory,
                        onChanged: (val) => setDialogState(() => isMandatory = val),
                      ),
                      SwitchListTile(
                        title: const Text('Pasif'),
                        value: isPassive,
                        onChanged: (val) => setDialogState(() => isPassive = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (_isSubmitting) const CircularProgressIndicator(),
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setDialogState(() => _isSubmitting = true);
                      
                      try {
                        // 1. Gönderilecek DTO'yu oluştur
                        DocumentTypeRuleDto ruleDto;
                        if (isEditing) {
                          // Düzenleme modu: Mevcut kuralı güncelle
                          existingRule.documentTypeId = docIdController.text;
                          existingRule.displayName = displayNameController.text;
                          existingRule.isMandatory = isMandatory;
                          existingRule.isPassive = isPassive;
                          ruleDto = DocumentTypeRuleDto.fromExisting(existingRule, _selectedEntity!.entityName);
                        } else {
                          // Ekleme modu: Yeni kural oluştur
                          ruleDto = DocumentTypeRuleDto.createNew(
                            entityType: _selectedEntity!.entityName,
                            documentTypeId: docIdController.text,
                            displayName: displayNameController.text,
                            isMandatory: isMandatory,
                            isPassive: isPassive,
                            attachmentsCount: 0,
                          );
                        }

                        // 2. API'yi çağır
                        await _apisettings.setDocumentTypeRule(ruleDto);
                        
                        // 3. Başarılı olduysak, diyalogu kapat ve güncellenmiş/yeni veriyi geri döndür
                        final displayItem = RequiredDocumentDto(
                          id: ruleDto.id, // API'den dönen ID veya yeni oluşturulan ID
                          documentTypeId: ruleDto.documentTypeId, 
                          displayName: ruleDto.displayName, 
                          isMandatory: ruleDto.isMandatory, 
                          isPassive: ruleDto.isPassive,
                          attachmentsCount: ruleDto.attachmentsCount,
                        );
                        
                        setDialogState(() => _isSubmitting = false);
                        Navigator.pop(dialogContext, displayItem);

                      } catch (e) {
                        setDialogState(() => _isSubmitting = false);
                        _showError('Hata: $e');
                      }
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );

    // Diyalogdan başarılı bir şekilde bir öğe döndüyse, listeyi UI'da güncelle
    if (result != null && mounted) {
      setState(() {
        if (isEditing) {
          // Düzenleme: Listedeki eski öğeyi bul ve yenisiyle değiştir
          final index = _definitions.indexWhere((d) => d.id == result.id);
          if (index != -1) {
            _definitions[index] = result;
          }
        } else {
          // Ekleme: Listeye yeni öğeyi ekle
          _definitions.add(result);
        }
        _definitions.sort((a,b) => a.displayName.compareTo(b.displayName));
      });
      _showSuccess(isEditing ? 'Kural başarıyla güncellendi.' : 'Yeni kural başarıyla eklendi.');
    }
  }

  // "Düzenle" artık ortak diyalog fonksiyonunu çağırıyor
  void _onEditDefinition(RequiredDocumentDto definition) {
    _showRuleDialog(existingRule: definition);
  }

  void _onDeleteDefinition(RequiredDocumentDto definition) {
    // TODO: Adım 4 (Sil)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dosya Tip Tanımları')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownSearch<EntityTypeDto>(
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(labelText: 'Entity ara...', border: OutlineInputBorder()),
                ),
              ),
              items: _entities,
              itemAsString: (EntityTypeDto e) => e.display,
              selectedItem: _selectedEntity,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(labelText: 'Entity Seçin', border: OutlineInputBorder()),
              ),
              onChanged: _onEntityChanged,
              enabled: !_isLoadingEntities,
            ),
          ),
          const Divider(height: 1),
          
          Expanded(
            child: _isLoadingDefinitions
                ? const Center(child: CircularProgressIndicator())
                : _selectedEntity == null
                    ? const Center(child: Text('Lütfen bir Entity seçin.'))
                    : _definitions.isEmpty
                        ? const Center(child: Text('Bu Entity için tanım bulunamadı.'))
                        // Tanımlar bulunduysa, ListView'da göster
                        : ListView.builder(
                            itemCount: _definitions.length,
                            itemBuilder: (context, index) {
                              final def = _definitions[index];
                              return _buildDefinitionCard(def);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: _selectedEntity == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showRuleDialog(), // "Ekle" modu için parametresiz çağır
              tooltip: 'Yeni Tanım Ekle',
              child: const Icon(Icons.add),
            ),
    );
  }

  // --- KARTVİEW GÜNCELLENDİ ---
  Widget _buildDefinitionCard(RequiredDocumentDto definition) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(definition.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(definition.documentTypeId),
            const SizedBox(height: 4),
            Row(
              children: [
                // Zorunlu Bilgisi
                Icon(
                  definition.isMandatory ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: definition.isMandatory ? Colors.red : Colors.grey,
                  size: 16,
                ),
                Text(' Zorunlu', style: TextStyle(color: definition.isMandatory ? Colors.red : Colors.grey, fontSize: 12)),
                const SizedBox(width: 12),
                // Pasif Bilgisi
                Icon(
                  definition.isPassive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: definition.isPassive ? Colors.grey : Colors.blue,
                  size: 16,
                ),
                Text(definition.isPassive ? ' Pasif' : ' Aktif', style: TextStyle(color: definition.isPassive ? Colors.grey : Colors.blue, fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              tooltip: 'Düzenle',
              onPressed: () => _onEditDefinition(definition),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              tooltip: 'Sil',
              onPressed: () => _onDeleteDefinition(definition),
            ),
          ],
        ),
      ),
    );
  }
}