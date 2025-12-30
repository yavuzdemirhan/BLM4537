import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart';
import '../services/api_service.dart';
import '../utils/image_helper.dart';
import 'tour_detail_screen.dart';
import 'add_tour_screen.dart';
import 'favorites_screen.dart';
import 'my_activities_screen.dart';
import 'profile_screen.dart';

// --- WRAPPER ---
class MainScreenWrapper extends StatefulWidget {
  final int initialIndex;
  const MainScreenWrapper({super.key, this.initialIndex = 0});
  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  late int _currentIndex;
  @override
  void initState() { super.initState(); _currentIndex = widget.initialIndex; }

  final List<Widget> _pages = [
    const HomeScreen(),
    const FavoritesScreen(),
    const MyActivitiesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTourScreen()));
          setState(() {});
        },
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        shape: const CircleBorder(), 
        elevation: 10,
        child: const Icon(Icons.add, size: 32),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
          color: Colors.black,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.redAccent, 
          unselectedItemColor: Colors.grey[700],
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: "Keşfet"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: "Favoriler"),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), activeIcon: Icon(Icons.event_note), label: "Etkinlikler"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profil"),
          ],
        ),
      ),
    );
  }
}

// --- ANA EKRAN ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  String _selectedCategory = "Tümü";
  String _searchQuery = "";
  String _username = "Sürücü";
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> _categories = ["Tümü", "Touring", "Enduro", "Racing", "Chopper"];

  @override
  void initState() { super.initState(); _loadUser(); }
  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _username = prefs.getString('saved_username') ?? "Sürücü");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: RefreshIndicator(
        onRefresh: () async { setState(() {}); },
        color: Colors.redAccent,
        backgroundColor: Colors.grey[900],
        child: CustomScrollView(
          slivers: [
            // 1. MODERN HEADER
            SliverAppBar(
              pinned: true, 
              expandedHeight: 200, 
              backgroundColor: const Color(0xFF121212),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Arka Plan
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black, Colors.red[900]!.withOpacity(0.2)],
                            begin: Alignment.bottomLeft, end: Alignment.topRight
                          )
                        ),
                      ),
                    ),
                    // Büyük Başlık
                    Positioned(
                      left: 20, bottom: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SELAM $_username,".toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          const Text(
                            "ROTA\nBELİRLE", 
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 36, 
                              fontWeight: FontWeight.w900, 
                              height: 0.9,
                              fontFamily: 'Roboto',
                              letterSpacing: -1.0
                            )
                          ),
                        ],
                      ),
                    ),
                    // Sağ Üst Profil
                    Positioned(
                      top: 60, right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent)),
                        child: const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://i.pravatar.cc/300")),
                      ),
                    ),
                    // Arama Barı
                    Positioned(
                      left: 20, right: 20, bottom: 20,
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E), 
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))]
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: "Nereye gidiyoruz?",
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.redAccent, size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // 2. KATEGORİLER
            SliverToBoxAdapter(
              child: Container(
                height: 35,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _categories.length,
                  itemBuilder: (c, i) => _buildChip(_categories[i], _selectedCategory == _categories[i]),
                ),
              ),
            ),

            // 3. GRID KARTLAR (KOMPAKT & DOLU DOLU)
            FutureBuilder<List<Tour>>(
              future: _apiService.getAllTours(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.redAccent)));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const SliverFillRemaining(child: Center(child: Text("Henüz rota yok.", style: TextStyle(color: Colors.white))));

                final allTours = snapshot.data!;
                final filtered = allTours.where((t) {
                  final matchesCategory = _selectedCategory == "Tümü" || t.motosikletKategorisi == _selectedCategory;
                  final matchesSearch = t.baslik.toLowerCase().contains(_searchQuery.toLowerCase()) || t.rota.toLowerCase().contains(_searchQuery.toLowerCase());
                  return matchesCategory && matchesSearch;
                }).toList();

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Kenar boşlukları biraz azaldı
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // ARTIK 3 SÜTUN
                      childAspectRatio: 0.68, // Kartın boy/en oranı (Dikdörtgen formunu korumak için ayarlandı)
                      crossAxisSpacing: 8, // Kartlar arası boşluk azaldı
                      mainAxisSpacing: 8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAnimCard(context, filtered[index]),
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD32F2F) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[800]!),
        ),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.w600, fontSize: 13))),
      ),
    );
  }

Widget _buildAnimCard(BuildContext context, Tour tour) {
  final imageUrl = tour.customImageUrl != null && tour.customImageUrl!.isNotEmpty
      ? tour.customImageUrl!
      : ImageHelper.getImageByCategory(tour.motosikletKategorisi);

  return _ScaleCard(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TourDetailScreen(tour: tour, imageUrl: imageUrl))),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20), // Köşe yuvarlaklığı biraz azaltıldı (küçük kartta çok yuvarlak sırıtır)
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. RESİM ALANI (%55 - Görsellik ön planda kalsın) ---
          Expanded(
            flex: 55,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), // Üst köşeler uyumlu hale getirildi
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
                // KATEGORİ (SOL ÜST - MİNİ)
                Positioned(
                  top: 6, left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red[900]!.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tour.motosikletKategorisi.toUpperCase(),
                      // Font boyutu 17'den 9'a düşürüldü
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // RATING (SAĞ ÜST - MİNİ)
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 15), // İkon küçüldü
                        const SizedBox(width: 2),
                        Text(
                          tour.averageRating > 0 ? tour.averageRating.toStringAsFixed(1) : "-",
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- 2. İÇERİK ALANI (%45) ---
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Padding azaltıldı
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği dikeyde yay
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BAŞLIK (30px -> 15px)
                      Text(
                        tour.baslik,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.1),
                      ),
                      const SizedBox(height: 2),                

                      // ROTA (20px -> 11px)
                      Row(
                        children: [
                          const Icon(Icons.map, size: 17, color: Colors.redAccent), // İkon 12px
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              tour.rota,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[400], fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Text(
                        tour.aciklama,
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.2),
                      ),
                      
                      const SizedBox(height: 6),

                  // TARİH ve KİŞİ (En Alta Yaslı)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarih
                      Row(children: [
                        Icon(Icons.calendar_today, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text(
                          "${tour.tarih.day}.${tour.tarih.month}.${tour.tarih.year}",
                          style: TextStyle(color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ]),
                      const SizedBox(height: 2),
                      // Kaptan Adı
                      Row(children: [
                        Icon(Icons.person, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            tour.olusturanKisi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[400], fontSize: 15),
                          ),
                        ),
                      ]),
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
}
}

class _ScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _ScaleCard({required this.child, required this.onTap});
  @override
  State<_ScaleCard> createState() => _ScaleCardState();
}

class _ScaleCardState extends State<_ScaleCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(_controller); 
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) { _controller.reverse(); widget.onTap(); },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}