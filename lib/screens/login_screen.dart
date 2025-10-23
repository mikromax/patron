import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/config_service.dart';

import '../models/api_config_model.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
final _configService = ConfigService(); // ConfigService'i oluşturuyoruz
  bool _isLoading = false;
  String? _errorMessage;
bool _isDemoProfile = false;

  @override
  void initState() {
    super.initState();
    // Sayfa açılırken varsayılan profili kontrol et
    _checkIfDemoProfile();
  }
  Future<void> _checkIfDemoProfile() async {
    final ApiConfig? defaultConfig = await _configService.getDefaultConfig();
    if (defaultConfig != null && defaultConfig.nickname == 'Demo') {
      setState(() {
        _isDemoProfile = true;
      });
    } else {
      setState(() {
        _isDemoProfile = false;
      });
    }
  }
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final identityServerUrl = await _authService.getIdentityServerUrl();
        if (identityServerUrl == null) {
          throw Exception('Identity Server adresi yapılandırılmamış. Lütfen sağ üstteki ayarlar menüsünden kontrol edin.');
        }
        final success = await _authService.login(
          identityServerUrl,
          _usernameController.text,
          _passwordController.text,
        );
        if (success && mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- DEĞİŞİKLİK BURADA BAŞLIYOR ---
      appBar: AppBar(
        title: const Text('Kullanıcı Girişi'),
        // AppBar'ın sağına buton eklemek için 'actions' kullanılır
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'API Ayarları',
            onPressed: () {
              // main.dart'ta tanımladığımız isimlendirilmiş rotaya yönlendir
              Navigator.pushNamed(context, '/config');
              _checkIfDemoProfile();
            },
          ),
        ],
      ),
      // Arka plan resmiyle ilgili kod burada değil, body'deydi.
      // Sorun çıkardığı için şimdilik sade tasarıma geri dönelim.
      // Arka plan resmini daha sonra tekrar ele alabiliriz.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lütfen Giriş Yapın', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Kullanıcı Adı', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Kullanıcı adı boş olamaz' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Parola', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Parola boş olamaz' : null,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Giriş Yap'),
                  ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!, 
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_isDemoProfile)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      'Denemek için:\nKullanıcı: Demo | Parola: 123',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}