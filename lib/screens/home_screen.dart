import 'package:flutter/material.dart';
import '../models/tour_model.dart';
import '../services/api_service.dart';
import '../utils/image_helper.dart';
import 'add_tour_screen.dart';
import 'tour_detail_screen.dart';
import 'profile_screen.dart';

// --- MAIN WRAPPER (Alt Menü ve Navigasyon) ---
class MainScreenWrapper extends StatefulWidget {
  final int initialIndex;
  const MainScreenWrapper({super.key, this.initialIndex = 0});
  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      
      // Ekleme Butonu (Sadece Ana Sayfada)
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTourScreen()));
          setState(() {}); 
        },
        backgroundColor: Colors.redAccent,
        elevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Gelişmiş Alt Menü
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined, size: 28), activeIcon: Icon(Icons.explore, size: 28), label: 'Keşfet'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 28), activeIcon: Icon(Icons.person, size: 28), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// --- HOME SCREEN (Filtreleme ve Listeleme) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  
  // FİLTRELEME İÇİN GEREKLİ DEĞİŞKEN
  String _selectedCategory = "Tümü"; 

  // Kategoriler Listesi
  final List<String> _categories = ["Tümü", "Touring", "Enduro", "Racing", "Chopper"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // 1. HAVALI SLIVER APP BAR (Yarışçı Teması)
          SliverAppBar(
            floating: true,
            pinned: true, 
            expandedHeight: 120,
            backgroundColor: Colors.redAccent,
            elevation: 5,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFFF5252)], 
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.two_wheeler, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "MOTO ROTA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900, 
                        fontStyle: FontStyle.italic, 
                        letterSpacing: 2.0,
                        shadows: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(2, 2))],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. KATEGORİ FİLTRELERİ 
          SliverToBoxAdapter(
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildChip(category, _selectedCategory == category);
                },
              ),
            ),
          ),

          // 3. LİSTE (Filtreye Göre Veri Getirir)
          FutureBuilder<List<Tour>>(
            future: _apiService.getAllTours(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.red)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text("Rota yok. İlk sen ekle!")));
              }

              // Backend'den gelen ham liste
              final allTours = snapshot.data!;
              
              // FİLTRELEME MANTIĞI
              // Eğer "Tümü" seçili değilse, sadece seçilen kategoriye uyanları al.
              final filteredTours = _selectedCategory == "Tümü"
                  ? allTours
                  : allTours.where((t) => t.motosikletKategorisi == _selectedCategory).toList();

              if (filteredTours.isEmpty) {
                 return const SliverFillRemaining(child: Center(child: Text("Bu kategoride henüz tur yok.")));
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCard(context, filteredTours[index]),
                  childCount: filteredTours.length,
                ),
              );
            },
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  // TIKLANABİLİR CHIP (Buton)
  Widget _buildChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Tıklanınca seçili kategoriyi güncelle ve ekranı yenile
        setState(() {
          _selectedCategory = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), 
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.redAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.redAccent : Colors.grey.shade300),
          boxShadow: isSelected 
              ? [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] 
              : [],
        ),
        child: Center(
          child: Text(
            label, 
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87, 
              fontWeight: FontWeight.bold
            )
          )
        ),
      ),
    );
  }

  // ANİMASYONLU KART (InkWell ile)
  Widget _buildCard(BuildContext context, Tour tour) {
    final imageUrl = ImageHelper.getImageByCategory(tour.motosikletKategorisi);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      
      child: Material(
        color: Colors.transparent, 
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => TourDetailScreen(tour: tour, imageUrl: imageUrl)));
          },
          splashColor: Colors.red.withOpacity(0.2), 
          highlightColor: Colors.red.withOpacity(0.1), 
          child: Column(
            children: [
              Hero(
                tag: "img-${tour.id}",
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        Text(tour.baslik, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                          decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)), 
                          child: Text(tour.motosikletKategorisi, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.map, size: 16, color: Colors.grey), 
                        const SizedBox(width: 4), 
                        Text(tour.rota, style: const TextStyle(color: Colors.grey))
                      ]
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}