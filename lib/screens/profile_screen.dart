import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = "Yükleniyor...";
  String _email = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Verileri çekme fonksiyonu
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Eğer veri yoksa 'Misafir' yazar
      _username = prefs.getString('saved_username') ?? "Misafir Sürücü";
      _email = prefs.getString('saved_email') ?? "Giriş Yapılmadı";
    });
    print("Profil Ekranı Yüklendi. Okunan İsim: $_username");
  }

  // ÇIKIŞ FONKSİYONU (GÜNCELLENDİ)
  void _logout() async {
    print("Çıkış butonuna basıldı...");
    
    await ApiService().logout();

    // Hata olsa bile kullanıcıyı zorla giriş ekranına at
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()), 
        (Route<dynamic> route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.redAccent, Color(0xFFB71C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(radius: 60, backgroundImage: NetworkImage("https://i.pravatar.cc/300")), 
                  ),
                ),
                Positioned(
                  top: 80, 
                  child: Column(
                    children: [
                      Text(_username, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(_email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  )
                ),
              ],
            ),
            const SizedBox(height: 60),
            
            // --- MENÜ KISMI ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildProfileMenu(Icons.settings, "Ayarlar"),
                  const Divider(),
                  
                  // ÇIKIŞ BUTONU
                  ListTile(
                    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.logout, color: Colors.red)),
                    title: const Text("Çıkış Yap", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    
                    // Tıklama olayı buraya bağlı
                    onTap: () {
                      _logout();
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String text) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.black87)),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}