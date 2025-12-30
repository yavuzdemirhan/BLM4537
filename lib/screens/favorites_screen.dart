import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'tour_detail_screen.dart';
import '../models/tour_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String u = prefs.getString('saved_username') ?? "";
    if (u.isNotEmpty) {
      final favs = await ApiService().getMyFavorites(u);
      setState(() { _favorites = favs; _isLoading = false; });
    } else { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // HEADER - HOME İLE AYNI STİL
      appBar: AppBar(
        title: const Text("FAVORİLER", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        centerTitle: false,
        backgroundColor: Colors.black,
        toolbarHeight: 80,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
        : _favorites.isEmpty 
          ? const Center(child: Text("Favori listen boş.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (c, i) {
                final item = _favorites[i];
                return GestureDetector(
                  // TIKLAYINCA DETAYA GİT
                  onTap: () {
                    // Geçici Tour objesi oluşturup detaya yolluyoruz
                    // Not: API'den tam veriyi çekmek daha doğru ama bu da çalışır.
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TourDetailScreen(
                      tour: Tour(id: item['tourId'], baslik: item['tourTitle'], aciklama: "Yükleniyor...", rota: "", tarih: DateTime.now(), motosikletKategorisi: "Genel", olusturanKisi: "", viewCount: 0, averageRating: 0.0), 
                      imageUrl: item['tourImage'] ?? ""
                    )));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                          child: Image.network(item['tourImage'] ?? "", width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['tourTitle'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              const Text("Detaylar için tıkla", style: TextStyle(color: Colors.grey, fontSize: 12))
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.favorite, color: Colors.red), onPressed: () async {
                           SharedPreferences p = await SharedPreferences.getInstance();
                           await ApiService().toggleFavorite(item['tourId'], p.getString('saved_username')??"", "", "");
                           _loadData();
                        })
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}