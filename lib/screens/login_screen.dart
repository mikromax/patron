import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final identityServerUrl = await _authService.getIdentityServerUrl();
        if (identityServerUrl == null) {
          throw Exception('Identity Server adresi yapılandırılmamış.');
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
      // Widget'ları üst üste koymak için Stack kullanıyoruz.
      body: Stack(
        children: [
          // 1. Katman: Arka Plan Görseli
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_background.jpg'),
                // Görselin ekranı tamamen kaplamasını sağlar
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. Katman: Karartıcı/Flu Efekt için Overlay
          Container(
            color: Colors.black.withOpacity(0.5), // Rengi ve şeffaflığı buradan ayarlayabilirsiniz
          ),
          // 3. Katman: Login Formu
          Center(
            child: SingleChildScrollView( // Klavye açıldığında taşmayı önler
              padding: const EdgeInsets.all(24.0),
              child: Card(
                // Formu yarı şeffaf bir kart içine alarak "buzlu cam" efekti veriyoruz
                color: Colors.white.withOpacity(0.9),
                elevation: 8.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
                      children: [
                        Text(
                          'Yönetici Paneli', 
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor, // Ana temadan renk al
                          )
                        ),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}