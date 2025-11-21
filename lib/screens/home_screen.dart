import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/UserSettings/user_widget_dto.dart';
import '../widgets/scorecard_widget.dart';
import 'ai_chat_screen.dart';
import 'main_menu_screen.dart';

// Her bir scorecard'ın statik bilgilerini (renk, ikon, başlık)
// ve API'deki WidgetId'sini eşleştirmek için bir sınıf
class ScorecardDefinition {
  final String widgetId; // API'den gelen 'widgetId' (örn: 'nakit_varliklar')
  final String title;
  final IconData icon;
  final Color color;

  ScorecardDefinition({
    required this.widgetId,
    required this.title,
    required this.icon,
    required this.color,
  });
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  final Map<String, ScorecardDefinition> _allScorecardsMap = {
    'nakit_varliklar': ScorecardDefinition(widgetId: 'nakit_varliklar', title: 'Nakit Varlıklar', icon: Icons.account_balance_wallet, color: Colors.green),
    'borclar': ScorecardDefinition(widgetId: 'borclar', title: 'Borçlar', icon: Icons.money_off, color: Colors.red),
    'alacaklar': ScorecardDefinition(widgetId: 'alacaklar', title: 'Alacaklar', icon: Icons.trending_up, color: Colors.blueAccent),
    'krediler': ScorecardDefinition(widgetId: 'krediler', title: 'Krediler', icon: Icons.credit_card, color: Colors.orange),
    'stoklar': ScorecardDefinition(widgetId: 'stoklar', title: 'Stoklar', icon: Icons.inventory, color: Colors.purple),
    'degerli_kagitlar': ScorecardDefinition(widgetId: 'degerli_kagitlar', title: 'Değerli Kağıtlar', icon: Icons.assessment, color: Colors.teal),
  };
  // Ana ekranın göstereceği, filtrelenmiş ve sıralanmış scorecard'ların listesi
  late Future<List<ScorecardDefinition>> _visibleScorecardsFuture;
 @override
  void initState() {
    super.initState();
    _visibleScorecardsFuture = _loadVisibleScorecards();
  }
// Kullanıcının yetkilerini çeken ve görünür olanları hazırlayan fonksiyon
  Future<List<ScorecardDefinition>> _loadVisibleScorecards() async {
    List<UserWidgetDto> permissions = await _authService.getWidgetPermissions();

    // Güvenlik: Eğer bir sebepten yetkiler çekilemediyse (örn: login sonrası hata oldu)
    // tekrar çekmeyi dene.
    if (permissions.isEmpty) {
      try {
        await _authService.fetchAndSaveWidgetPermissions();
        permissions = await _authService.getWidgetPermissions();
      } catch (e) {
        debugPrint(e.toString());
        return []; // Hata durumunda boş liste göster
      }
    }

    // 1. Filtrele: Sadece görünür olanları al
    var visible = permissions.where((p) => p.isVisible);

    // 2. Sırala: 'sortOrder'a göre küçükten büyüğe sırala
    var sorted = visible.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    // 3. Eşleştir: 'widgetId'yi kullanarak statik tanımlarla (ikon, renk) birleştir
    List<ScorecardDefinition> finalScorecards = [];
    for (var perm in sorted) {
      if (_allScorecardsMap.containsKey(perm.widgetId)) {
        finalScorecards.add(_allScorecardsMap[perm.widgetId]!);
      }
    }
    
    return finalScorecards;
  }
  void _logoutAndGoToLogin() {
    _authService.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
  
  void _navigateToConfig() {
      Navigator.pushNamed(context, '/config');
  }
  
  void _navigateToAIChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIChatScreen()),
    );
  }
  // Ana Menüye Giden Yol
void _navigateToMainMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Artık argüman göndermiyoruz, sadece root menüyü çağırıyoruz.
        builder: (context) => const MainMenuScreen.root(),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                _navigateToConfig();
              } else if (value == 'logout'){
                _logoutAndGoToLogin();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(value: 'settings', child: Text('API Ayarları')),
              const PopupMenuItem<String>(value: 'logout', child: Text('Çıkış Yap')),
            ],
          ),
        ],
      ),
    
      // Arayüzü alt alta dizmek için Column kullanıyoruz.
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                // 1. YENİ MENÜ BUTONU
                IconButton(
                  icon: const Icon(Icons.menu),
                  iconSize: 30,
                  tooltip: 'Ana Menü',
                  onPressed: _navigateToMainMenu,
                ),
                
                // 2. MEVCUT AI KARTI (Expanded ile sardık)
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: _navigateToAIChat,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Yapay Zeka ile Sorgula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text('Doğal dilde raporlar oluşturun.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 3. ELEMAN: MEVCUT SCORECARD GRİD'İ
          // Expanded, GridView'ın kalan tüm dikey alanı kaplamasını sağlar.
          Expanded(
            child: FutureBuilder<List<ScorecardDefinition>>(
              future: _visibleScorecardsFuture,
              builder: (context, snapshot) {
                // Yükleniyor durumu
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Hata durumu
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }
                // Başarılı ama veri yok durumu
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Görüntülenecek yetkili bir widget bulunamadı.'));
                }

                // Başarılı: Dinamik listeyi oluştur
                final visibleScorecards = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: visibleScorecards.length,
                  itemBuilder: (context, index) {
                    final scorecard = visibleScorecards[index];
                    return ScorecardWidget(
                      title: scorecard.title,
                      icon: scorecard.icon,
                      color: scorecard.color,
                      apiEndpoint: scorecard.widgetId,
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