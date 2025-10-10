import 'package:flutter/material.dart';
import '../models/scorecard_model.dart';
import '../services/auth_service.dart';
import '../widgets/scorecard_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  // Şimdilik test verisi olarak 6 scorecard'ı burada oluşturuyoruz.
  // İleride bu liste API'den gelen veriye göre dinamik olarak dolacak.
  final List<ScorecardModel> _scorecards = [
    ScorecardModel(title: 'Nakit Varlıklar', value: '₺150.750', icon: Icons.account_balance_wallet, color: Colors.green),
    ScorecardModel(title: 'Borçlar', value: '₺45.200', icon: Icons.money_off, color: Colors.red),
    ScorecardModel(title: 'Alacaklar', value: '₺88.900', icon: Icons.trending_up, color: Colors.blueAccent),
    ScorecardModel(title: 'Krediler', value: '₺120.000', icon: Icons.credit_card, color: Colors.orange),
    ScorecardModel(title: 'Stoklar', value: '₺210.500', icon: Icons.inventory, color: Colors.purple),
    ScorecardModel(title: 'Değerli Kağıtlar', value: '₺75.000', icon: Icons.assessment, color: Colors.teal),
  ];
  
  void _logoutAndGoToLogin() {
    _authService.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
  
  void _navigateToConfig() {
      Navigator.pushNamed(context, '/config');
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
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        // GridView'ın yapısını tanımlıyoruz.
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Her satırda 2 kart
          childAspectRatio: 0.9, // Kartların en-boy oranı
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _scorecards.length, // Listede kaç eleman varsa o kadar kart çiz
        itemBuilder: (context, index) {
          // Her bir eleman için bir ScorecardWidget oluşturuyoruz.
          return ScorecardWidget(model: _scorecards[index]);
        },
      ),
    );
  }
}