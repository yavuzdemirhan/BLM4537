import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  // Kullanıcı Verileri
  String _username = "Yükleniyor...";
  String _email = "";
  String _profilePicUrl = "https://i.pravatar.cc/300"; // Varsayılan resim
  
  // İstatistikler ve Veriler
  Map<String, dynamic> _stats = {"followers": 0, "following": 0};
  Map<String, dynamic>? _sosInfo;
  List<Map<String, dynamic>> _myBikes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String u = prefs.getString('saved_username') ?? "Misafir";
    String e = prefs.getString('saved_email') ?? "";
    String p = prefs.getString('profile_pic_url') ?? "https://i.pravatar.cc/300"; 
    
    // API İstekleri
    final stats = await _apiService.getFollowStats(u);
    final sos = await _apiService.getSOS(u);
    final bikes = await _apiService.getMyBikes(u);

    if (mounted) setState(() {
      _username = u; 
      _email = e; 
      _stats = stats; 
      _sosInfo = sos; 
      _myBikes = bikes; 
      _profilePicUrl = p;
    });
  }

  // --- 1. PROFİL RESMİ DEĞİŞTİRME ---
  void _changeAvatarDialog() {
    final urlCtrl = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Profil Resmini Değiştir", style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: urlCtrl, 
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Resim Linki (URL)", 
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
        )
      ),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
          onPressed: () async {
            if(urlCtrl.text.isNotEmpty) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('profile_pic_url', urlCtrl.text);
              setState(() => _profilePicUrl = urlCtrl.text);
            }
            Navigator.pop(c);
          }, 
          child: const Text("Kaydet", style: TextStyle(color: Colors.white))
        )
      ],
    ));
  }

  // --- 2. MOTOR EKLEME ---
  void _addBikeDialog() {
    final brandCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final ccCtrl = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Garaja Motor Ekle", style: TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _darkInput(brandCtrl, "Marka (Yamaha)"),
        _darkInput(modelCtrl, "Model (MT-07)"),
        _darkInput(ccCtrl, "Motor Hacmi (cc)"),
      ]),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
          onPressed: () async {
            await _apiService.addBike(_username, brandCtrl.text, modelCtrl.text, 2024, int.tryParse(ccCtrl.text)??0);
            Navigator.pop(c); 
            _loadData();
          }, 
          child: const Text("Ekle", style: TextStyle(color: Colors.white))
        )
      ],
    ));
  }

  // --- 3. SOS KARTI DÜZENLEME (TAMİR EDİLDİ) ---
  void _editSOSDialog() {
    final bloodCtrl = TextEditingController(text: _sosInfo?['bloodType']??"");
    final nameCtrl = TextEditingController(text: _sosInfo?['emergencyContactName']??"");
    final phoneCtrl = TextEditingController(text: _sosInfo?['emergencyContactPhone']??"");
    final noteCtrl = TextEditingController(text: _sosInfo?['notes']??"");

    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Row(children: [Icon(Icons.medical_services, color: Colors.red), SizedBox(width: 10), Text("SOS Bilgileri", style: TextStyle(color: Colors.white))]),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _darkInput(bloodCtrl, "Kan Grubu (0 Rh+)"),
          _darkInput(nameCtrl, "Acil Kişi Adı"),
          _darkInput(phoneCtrl, "Acil Kişi Tel"),
          _darkInput(noteCtrl, "Tıbbi Notlar / Alerjiler"),
        ]),
      ),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
          onPressed: () async {
            await _apiService.saveSOS(_username, bloodCtrl.text, nameCtrl.text, phoneCtrl.text, noteCtrl.text);
            Navigator.pop(c); 
            _loadData();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SOS Bilgileri Güncellendi")));
          }, 
          child: const Text("Kaydet", style: TextStyle(color: Colors.white))
        )
      ],
    ));
  }

  Widget _darkInput(TextEditingController c, String h) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c, 
      style: const TextStyle(color: Colors.white), 
      decoration: InputDecoration(
        hintText: h, 
        hintStyle: const TextStyle(color: Colors.grey), 
        filled: true, 
        fillColor: Colors.black,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)
      )
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ÜST KART
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Koyu Gri Kart
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 15, offset: const Offset(0, 5))]
              ),
              child: Column(children: [
                // PROFİL RESMİ VE DÜZENLEME
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent, width: 2)),
                      child: CircleAvatar(radius: 55, backgroundImage: NetworkImage(_profilePicUrl), backgroundColor: Colors.grey[900]),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: _changeAvatarDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Text(_username, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                Text(_email, style: const TextStyle(color: Colors.grey)),
                
                const SizedBox(height: 25),
                
                // İSTATİSTİKLER
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _statItem("Takipçi", "${_stats['followers']}"),
                  Container(width: 1, height: 40, color: Colors.white10), 
                  _statItem("Takip", "${_stats['following']}"),
                  Container(width: 1, height: 40, color: Colors.white10), 
                  _statItem("Motor", "${_myBikes.length}"),
                ]),
                
                const SizedBox(height: 25),
                
                // SOS BUTONU 
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900], 
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5
                  ),
                  icon: const Icon(Icons.medical_services_outlined), 
                  label: const Text("ACİL DURUM KARTI (SOS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  onPressed: _editSOSDialog 
                ))
              ]),
            ),
            
            const SizedBox(height: 15),
            
            // TAB BAR 
            TabBar(
              controller: _tabController, 
              labelColor: Colors.redAccent, 
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.redAccent,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.two_wheeler), SizedBox(width: 8), Text("Garajım")])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.settings), SizedBox(width: 8), Text("Ayarlar")])),
              ]
            ),
            
            // SEKME İÇERİKLERİ
            SizedBox(
              height: 400, // İçerik yüksekliği
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. GARAJ TABI
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C2C2C), minimumSize: const Size(double.infinity, 50)),
                        onPressed: _addBikeDialog, 
                        child: const Text("+ Yeni Motor Ekle", style: TextStyle(color: Colors.white))
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: _myBikes.isEmpty 
                        ? const Center(child: Text("Garajın boş.", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _myBikes.length,
                            itemBuilder: (c, i) {
                              final b = _myBikes[i];
                              return Card(
                                color: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.two_wheeler, color: Colors.redAccent, size: 24)),
                                  title: Text("${b['brand']} ${b['model']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  subtitle: Text("${b['engineCc']}cc - ${b['year']}", style: const TextStyle(color: Colors.grey)),
                                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                                    await _apiService.deleteBike(b['id']); 
                                    _loadData();
                                  }),
                                ),
                              );
                            }
                        ),
                      )
                    ]),
                  ),
                  
                  // 2. AYARLAR TABI
                  ListView(padding: const EdgeInsets.all(16), children: [
                    ListTile(
                      tileColor: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: const Icon(Icons.logout, color: Colors.red), 
                      title: const Text("Çıkış Yap", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
                      onTap: () async {
                        await _apiService.logout();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c)=>const WelcomeScreen()), (r)=>false);
                      }
                    ),
                    const SizedBox(height: 10),
                    const Center(child: Text("v4.2.0 - Ultimate Edition", style: TextStyle(color: Colors.grey, fontSize: 12)))
                  ])
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.0)),
      ],
    );
  }
}