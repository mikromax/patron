import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/Helpers/base_card_view_model.dart';
import '../../models/UserSettings/create_custom_menu_item_dto.dart';
import '../../models/UserSettings/user_menu_dto.dart';
import '../../models/UserSettings/program_definition_dto.dart';
import '../../services/api/settings_api.dart';
import '../../utils/icon_helper.dart';

class MenuLinesScreen extends StatefulWidget {
  final BaseCardViewModel menuHeader;
  const MenuLinesScreen({super.key, required this.menuHeader});

  @override
  State<MenuLinesScreen> createState() => _MenuLinesScreenState();
}

class _MenuLinesScreenState extends State<MenuLinesScreen> {
  final SettingsApi _api = SettingsApi();
  bool _isLoading = true;
  List<UserMenuDto> _items = [];
  List<ProgramDefinitionDto> _programs = []; // Dropdown için

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      // Paralel olarak hem menü satırlarını hem de program listesini çek
      final itemsFuture = _api.getCustomMenuItems(widget.menuHeader.id);
      final programsFuture = _api.getAllAvailablePrograms();
      
      final results = await Future.wait([itemsFuture, programsFuture]);
      
      setState(() {
        _items = (results[0] as List<UserMenuDto>)..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        _programs = results[1] as List<ProgramDefinitionDto>;
        _isLoading = false;
      });
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      await _api.deleteMenuItemFromCustomMenu(id);
      _loadData(); // Yenile
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silindi'), backgroundColor: Colors.green));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Future<void> _showAddItemDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final pathController = TextEditingController(text: '/');
    final orderController = TextEditingController(text: ((_items.length + 1) * 10).toString());
    ProgramDefinitionDto? selectedProgram;
    String? selectedIconKey;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yeni Satır Ekle'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Görünüm Adı'), validator: (v) => v!.isEmpty ? 'Gerekli' : null),
                  TextFormField(controller: pathController, decoration: const InputDecoration(labelText: 'Yol (örn: /Muhasebe)'), validator: (v) => v!.isEmpty ? 'Gerekli' : null),
                  
                  DropdownSearch<ProgramDefinitionDto>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: _programs,
                    itemAsString: (p) => p.display,
                    dropdownDecoratorProps: const DropDownDecoratorProps(dropdownSearchDecoration: InputDecoration(labelText: 'Program')),
                    onChanged: (v) => selectedProgram = v,
                    validator: (v) => v == null ? 'Gerekli' : null,
                  ),
                  
                  DropdownButtonFormField<String>(
                    initialValue: selectedIconKey,
                    decoration: const InputDecoration(labelText: 'İkon'),
                    items: IconHelper.getIconDropdownItems(),
                    onChanged: (v) => setDialogState(() => selectedIconKey = v),
                    validator: (v) => v == null ? 'Gerekli' : null,
                  ),
                  
                  TextFormField(controller: orderController, decoration: const InputDecoration(labelText: 'Sıra No'), keyboardType: TextInputType.number),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() => isSubmitting = true);
                  try {
                    final dto = CreateCustomMenuItemDto(
                      customMenuId: widget.menuHeader.id,
                      programNo: selectedProgram!.programNo,
                      displayName: nameController.text,
                      path: pathController.text,
                      icon: selectedIconKey!,
                      sortOrder: int.tryParse(orderController.text) ?? 0,
                    );
                    await _api.addMenuItemToCustomMenu(dto);
                    if(mounted) {
                      Navigator.pop(context);
                      _loadData(); // Listeyi yenile
                    }
                  } catch (e) {
                    setDialogState(() => isSubmitting = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                  }
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.menuHeader.description} - Satırlar')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: Icon(IconHelper.getIconFromString(item.icon)),
                  title: Text(item.displayName),
                  subtitle: Text('${item.path} (Prog: ${item.programNo})'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item.id),
                  ),
                );
              },
            ),
    );
  }
}