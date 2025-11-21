import 'dart:io';
import '../models/api_config_model.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/config_screen.dart';
import 'screens/home_screen.dart';
import 'services/config_service.dart';
import 'package:uuid/uuid.dart';
import 'package:patron/services/api/core/api_client.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  var ensureInitialized = WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  final configService = ConfigService();
  final authService = AuthService();
  ApiClient.initialize(navigatorKey);
List<ApiConfig> configs = await configService.getConfigs();
  

  // 2. Eğer hiç konfigürasyon yoksa, "Demo" profilini oluştur.
  if (configs.isEmpty) {
    final demoConfig = ApiConfig(
      id: Uuid().v4(),
      nickname: 'Demo',
      url: 'https://api.mikromax.com.tr',
    );
    
    // Yeni listeyi oluştur ve kaydet.
    configs.add(demoConfig);
    await configService.saveConfigs(configs);
    
    // Bu yeni "Demo" profilini varsayılan olarak ayarla.
    await configService.saveDefaultConfigId(demoConfig.id);
   
  }


  // 1. Config var mı?
  final defaultConfigId = await configService.getDefaultConfigId();
  // 2. Token var mı?
  final userIsLoggedIn = await authService.isLoggedIn();

  String initialRoute;
  if (defaultConfigId == null || defaultConfigId.isEmpty) {
    initialRoute = '/config'; // Config yoksa, ayarlar sayfasına git
  } else if (!userIsLoggedIn) {
    initialRoute = '/login'; // Config var ama giriş yapılmamışsa, login'e git
  } else {
    initialRoute = '/home'; // Her şey tamamsa, ana sayfaya git
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yönetici Paneli',
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      routes: {
        '/home': (context) => const HomeScreen(),
        '/config': (context) => const ConfigScreen(),
        '/login': (context) => const LoginScreen(), // Yeni login rotası
      },
    );
  }
}