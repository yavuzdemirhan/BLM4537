import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl = TextEditingController(); // Backend Username istiyor
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _handleRegister() async {
    if (_usernameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun."), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);
    
    // API İsteği (Username, Email, Password)
    bool success = await _apiService.register(_usernameCtrl.text, _emailCtrl.text, _passCtrl.text);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kayıt Başarılı! Giriş yapabilirsin."), backgroundColor: Colors.green));
      Navigator.pop(context); // Giriş ekranına dön
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kayıt başarısız. Bilgileri kontrol et."), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://images.unsplash.com/photo-1558981403-c5f9899a28bc?q=80&w=1000"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.7)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Icon(Icons.person_add_alt_1, size: 70, color: Colors.white),
                  const SizedBox(height: 15),
                  const Text("ARAMIZA KATIL", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),

                  // INPUTLAR
                  _buildInput(_usernameCtrl, "Kullanıcı Adı", Icons.person),
                  const SizedBox(height: 20),
                  _buildInput(_emailCtrl, "E-Posta", Icons.email),
                  const SizedBox(height: 20),
                  _buildInput(_passCtrl, "Şifre", Icons.lock, isPassword: true),
                  
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("KAYIT OL", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Zaten hesabın var mı? Giriş Yap", style: TextStyle(color: Colors.white70)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.redAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }
}