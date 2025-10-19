import 'package:flutter/material.dart';
import '../models/scorecard_model.dart';
import '../services/auth_service.dart';
import '../widgets/scorecard_widget.dart';
// Yeni AI Chat ekranımızı import ediyoruz (birazdan oluşturacağız)
import 'ai_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  final List<Map<String, dynamic>> _scorecardConfigs = [
    {
      'title': 'Nakit Varlıklar', 'icon': Icons.account_balance_wallet, 'color': Colors.green, 'apiEndpoint': 'nakit_varliklar'
    },
    {
      'title': 'Borçlar', 'icon': Icons.money_off, 'color': Colors.red, 'apiEndpoint': 'borclar'
    },
    {
      'title': 'Alacaklar', 'icon': Icons.trending_up, 'color': Colors.blueAccent, 'apiEndpoint': 'alacaklar'
    },
    {
      'title': 'Krediler', 'icon': Icons.credit_card, 'color': Colors.orange, 'apiEndpoint': null
    },
    {
      'title': 'Stoklar', 'icon': Icons.inventory, 'color': Colors.purple, 'apiEndpoint': null
    },
    {
      'title': 'Değerli Kağıtlar', 'icon': Icons.assessment, 'color': Colors.teal, 'apiEndpoint': null
    },
  ];
  
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
      // --- DEĞİŞİKLİK BURADA BAŞLIYOR ---
      // Arayüzü alt alta dizmek için Column kullanıyoruz.
      body: Column(
        children: [
          // 1. ELEMAN: YENİ AI SORGULAMA BUTONU
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
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
                      Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 30),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Yapay Zeka ile Sorgula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Doğal dilde sorular sorarak anında raporlar oluşturun.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 2. ELEMAN: MEVCUT SCORECARD GRİD'İ
          // Expanded, GridView'ın kalan tüm dikey alanı kaplamasını sağlar.
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _scorecardConfigs.length,
              itemBuilder: (context, index) {
                final config = _scorecardConfigs[index];
                return ScorecardWidget(
                  title: config['title'],
                  icon: config['icon'],
                  color: config['color'],
                  apiEndpoint: config['apiEndpoint'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}