import 'package:flutter/material.dart';
import '../models/UserSettings/user_menu_dto.dart';
import 'placeholders/generic_placeholder_screen.dart';
import '../../utils/icon_helper.dart'; // İkon yardımcısını import et
import 'UserSettings/widget_settings_screen.dart';
import 'UserSettings/user_detail_screen.dart';
import 'Approvals/document_approval_screen.dart';
import '../models/Approvals/approval_document_type.dart';
import '../screens/Attachments/file_definition_screen.dart';
import 'Documents/Finance/credit_limit_request_screen.dart';
import '../services/api/settings_api.dart';
import 'UserSettings/account_screen.dart';
import '../screens/UserSettings/menu_definitions_screen.dart';
import 'UserSettings/role_definitions_screen.dart';
import 'BusinessPartners/business_partner_list_screen.dart';
import 'ForeignTrade/HsCode/hs_code_screen.dart';
import 'UserSettings/context_switch_screen.dart';
import 'ForeignTrade/import_expense_idstributin_document.dart';
import 'Definitions/generic_card_screen.dart';
// Ekranda gösterilecek bir öğeyi temsil eder (Klasör veya Uygulama)
class MenuItem {
  final String name;
  final bool isFolder;
  final UserMenuDto? appData;

  MenuItem({required this.name, required this.isFolder, this.appData});
}

class MainMenuScreen extends StatefulWidget {
  final String currentPath;
  final String title;
  final List<UserMenuDto>? allMenuItems;

  const MainMenuScreen.root({super.key})
      : currentPath = '/',
        title = 'Ana Menü',
        allMenuItems = null;

  const MainMenuScreen.subfolder({
    super.key,
    required this.currentPath,
    required this.title,
    required this.allMenuItems,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final SettingsApi _apiService = SettingsApi();
  Future<List<UserMenuDto>>? _menuDataFuture;

  @override
  void initState() {
    super.initState();
    if (widget.allMenuItems == null) {
      _menuDataFuture = _apiService.getUserMenu();
    } else {
      _menuDataFuture = Future.value(widget.allMenuItems);
    }
  }

  List<MenuItem> _parseMenuForCurrentPath(List<UserMenuDto> allItems) {
    final Map<String, MenuItem> folders = {};
    final List<MenuItem> apps = [];
    final int currentDepth = widget.currentPath == '/' ? 0 : widget.currentPath.split('/').where((p) => p.isNotEmpty).length;

    for (var item in allItems) {
      if (item.path == widget.currentPath) {
        apps.add(MenuItem(name: item.displayName, isFolder: false, appData: item));
      } 
      else if (item.path.startsWith(widget.currentPath)) {
        var parts = item.path.split('/').where((p) => p.isNotEmpty).toList();
        if (parts.length > currentDepth) {
          String folderName = parts[currentDepth];
          if (!folders.containsKey(folderName)) {
            folders[folderName] = MenuItem(name: folderName, isFolder: true);
          }
        }
      }
    }
    
    var folderList = folders.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    apps.sort((a, b) => a.appData!.sortOrder.compareTo(b.appData!.sortOrder));
    
    return [...folderList, ...apps];
  }

  // --- DEĞİŞİKLİK BURADA: NAVİGASYON MANTIĞI EKLENDİ ---
  void _onItemTapped(MenuItem item, List<UserMenuDto> allItems) {
    if (item.isFolder) {
      // Bir klasöre tıklandı, alt klasör ekranını aç
      String newPath = widget.currentPath == '/' ? '/${item.name}' : '${widget.currentPath}/${item.name}';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenuScreen.subfolder(
            currentPath: newPath,
            title: item.name,
            allMenuItems: allItems,
          ),
        ),
      );
    } else {
      // Bir uygulamaya tıklandı. ProgramNo'ya göre yönlendir.
     if (item.appData?.programNo == 1101) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountScreen()));
      }
      else if (item.appData?.programNo == 1102) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const WidgetSettingsScreen()));
      }
    else if (item.appData?.programNo == 1103) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserDetailScreen()));
      }
      else if (item.appData?.programNo == 1104) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FileDefinitionScreen()));
      }
      else if (item.appData?.programNo == 1105) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RoleDefinitionsScreen()));
      }
      else if (item.appData?.programNo == 1107) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuDefinitionsScreen()));
      }
      else if (item.appData?.programNo == 4101) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CreditLimitRequestScreen()));
      }
      else if (item.appData?.programNo == 4103) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const BusinessPartnerListScreen()));
      }
      else if (item.appData?.programNo == 5101) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HsCodeScreen()));
      }
      else if (item.appData?.programNo == 5103) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ImportDocumentScreen()));
      }
      else if (item.appData?.programNo == 6101) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => const GenericCardScreen(
          pageTitle: 'Bölgeler',
          apiEndpoint: 'api/Regions', // API'nizin Base Path'i
          entityName: 'Region', // Dosya ekleri için Entity adı
        )
      ));
    }
    else if (item.appData?.programNo == 6102) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => const GenericCardScreen(
          pageTitle: 'Cari Grupları',
          apiEndpoint: 'api/BusinessPartnerGroups', // API'nizin Base Path'i
          entityName: 'BusinessPartnerGroup', // Dosya ekleri için Entity adı
        )
      ));
    }
    else if (item.appData?.programNo == 6103) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => const GenericCardScreen(
          pageTitle: 'Sektörler',
          apiEndpoint: 'api/BusinessSectors', // API'nizin Base Path'i
          entityName: 'BusinessSector', // Dosya ekleri için Entity adı
        )
      ));
    }
    else if (item.appData?.programNo == 6104) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => const GenericCardScreen(
          pageTitle: 'Ülkeler',
          apiEndpoint: 'api/Countries', // API'nizin Base Path'i
          entityName: 'Country', // Dosya ekleri için Entity adı
        )
      ));
    }
    
      else if (item.appData?.programNo == 2101 || item.appData?.programNo == 2102 || item.appData?.programNo == 3101 || item.appData?.programNo == 3102) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => DocumentApprovalScreen(
            title: item.name,
            documentType: ApprovalDocumentType.fromProgramNo(item.appData?.programNo),
          ),
        ));
      }
      else {
        // Diğer tüm programlar için şimdilik boş sayfayı aç
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GenericPlaceholderScreen(pageTitle: item.name),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),
      actions: [
          // Sadece root menüdeyken göster
          if (widget.currentPath == '/')
            IconButton(
              icon: const Icon(Icons.compare_arrows), // Veya Icons.sync
              tooltip: 'Firma/Tesis Değiştir',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContextSwitchScreen())
                ).then((needsRefresh) {
                  // Kullanıcı bağlamı değiştirdiyse
                  if (needsRefresh == true) {
                    // TODO: Ana Ekranı (HomeScreen) yenilememiz gerekiyor
                    // Bu, state management ile daha kolay olur.
                    // Şimdilik, menü ekranı zaten bağlamı okumadığı için
                    // sadece ana ekranın yenilenmesi gerekir.
                  }
                });
              },
            ),
        ],
      ),
      body: FutureBuilder<List<UserMenuDto>>(
        future: _menuDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Menü ayarları bulunamadı.'));
          }

          final allItems = snapshot.data!;
          final menuItems = _parseMenuForCurrentPath(allItems);

          if (menuItems.isEmpty) {
            return const Center(child: Text('Bu klasör boş.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              
              // --- DEĞİŞİKLİK BURADA: İKONLARI DOĞRU ALMA ---
              IconData iconData;
              if (item.isFolder) {
                iconData = IconHelper.getIconFromString('folder'); // Klasör için 'folder'
              } else {
                iconData = IconHelper.getIconFromString(item.appData?.icon); // Uygulama için API'den gelen ad
              }

              return InkWell(
                onTap: () => _onItemTapped(item, allItems),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconData, size: 48, color: Colors.indigo),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}