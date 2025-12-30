import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart';
import '../services/api_service.dart';
import 'tour_detail_screen.dart'; // Detay ekranı importu

class MyActivitiesScreen extends StatefulWidget {
  const MyActivitiesScreen({super.key});

  @override
  State<MyActivitiesScreen> createState() => _MyActivitiesScreenState();
}

class _MyActivitiesScreenState extends State<MyActivitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  String _username = "";
  
  // Veriler
  List<Tour> _joinedTours = [];
  List<Tour> _createdTours = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String u = prefs.getString('saved_username') ?? "";
    
    if (u.isNotEmpty) {
      // 1. Katıldıklarımı Çek
      var joined = await _apiService.getMyParticipations(u);
      // 2. Oluşturduklarımı Çek
      var created = await _apiService.getMyCreatedTours(u);

      if (mounted) {
        setState(() {
          _username = u;
          _joinedTours = joined;
          _createdTours = created;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- RESİM SEÇME MANTIĞI (MERKEZİ) ---
  String _getTourImage(Tour tour) {
    // 1. Özel resim varsa onu döndür
    if (tour.customImageUrl != null && tour.customImageUrl!.isNotEmpty) {
      return tour.customImageUrl!;
    }
    
    // 2. Yoksa kategoriye göre sabit resim döndür
    switch (tour.motosikletKategorisi.toLowerCase()) {
      case 'enduro':
      case 'cross':
        return "https://images.unsplash.com/photo-1558981285-6f0c94958bb6?q=80&w=1000&auto=format&fit=crop"; 
      case 'chopper':
      case 'cruiser':
        return "https://images.unsplash.com/photo-1558981403-c5f9899a28bc?q=80&w=1000&auto=format&fit=crop";
      case 'racing':
      case 'supersport':
        return "https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?q=80&w=1000&auto=format&fit=crop";
      case 'gezi':
      case 'touring':
        return "https://images.unsplash.com/photo-1609630875171-b1321377ee65?q=80&w=1000&auto=format&fit=crop";
      case 'scooter':
        return "https://images.unsplash.com/photo-1591635566278-10dca0ca76ee?q=80&w=1000&auto=format&fit=crop";
      default:
        return "https://images.unsplash.com/photo-1496660662244-a0c5b3d07718?q=80&w=1000&auto=format&fit=crop";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("ETKİNLİKLERİM", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.black,
        toolbarHeight: 80,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.redAccent,
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Katıldıklarım"),
            Tab(text: "Oluşturduklarım"),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _username.isEmpty
              ? const Center(child: Text("Lütfen giriş yapın", style: TextStyle(color: Colors.grey)))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTourList(_joinedTours, "Henüz bir tura katılmadın."),
                    _buildTourList(_createdTours, "Henüz bir tur oluşturmadın."),
                  ],
                ),
    );
  }

  // LİSTE OLUŞTURUCU
  Widget _buildTourList(List<Tour> tours, String emptyMsg) {
    if (tours.isEmpty) {
      return Center(child: Text(emptyMsg, style: const TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      color: Colors.redAccent,
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tours.length,
        itemBuilder: (context, index) {
          final tour = tours[index];
          // YENİ FONKSİYONU KULLANIYORUZ:
          final imageUrl = _getTourImage(tour);

          return GestureDetector(
            onTap: () async {
              // Detaya giderken belirlediğimiz resmi de gönderiyoruz
              await Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => TourDetailScreen(tour: tour, imageUrl: imageUrl)
                )
              );
              _loadData(); // Dönünce listeyi tazele
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  // --- SOL TARAFTA RESİM (AKILLI SEÇİM) ---
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                    child: Image.network(
                      imageUrl, 
                      width: 110, 
                      height: 110, 
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Container(width: 110, height: 110, color: Colors.grey[800], child: const Icon(Icons.broken_image)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // --- SAĞ TARAFTA BİLGİLER ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Başlık
                          Text(
                            tour.baslik, 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis, 
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 5),
                          
                          // Kategori Etiketi
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                            child: Text(tour.motosikletKategorisi.toUpperCase(), style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          
                          const Spacer(),
                          
                          // Tarih ve Ok
                          Row(
                            children: [
                              Text("${tour.tarih.day}.${tour.tarih.month}.${tour.tarih.year}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}