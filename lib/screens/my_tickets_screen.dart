import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart';
import '../services/api_service.dart';
import '../utils/image_helper.dart'; // Resim helper'ı ekledik
import 'tour_detail_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});
  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  String _username = "";
  bool _isLoading = true;
  List<Tour> _myTickets = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('saved_username') ?? "";
    
    if (_username.isNotEmpty) {
      // ARTIK List<Tour> BEKLİYORUZ, Map DEĞİL
      final tickets = await _apiService.getMyParticipations(_username);
      if(mounted) {
        setState(() {
          _myTickets = tickets;
          _isLoading = false;
        });
      }
    } else {
       if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("BİLETLERİM / KATILDIKLARIM", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.black,
        toolbarHeight: 80,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _myTickets.isEmpty
              ? const Center(child: Text("Henüz bir tura katılmadın.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myTickets.length,
                  itemBuilder: (context, index) {
                    final tour = _myTickets[index];
                    
                    // RESİM SEÇİMİ (Özel varsa özel, yoksa kategori)
                    final imageUrl = tour.customImageUrl != null && tour.customImageUrl!.isNotEmpty 
                        ? tour.customImageUrl! 
                        : ImageHelper.getImageByCategory(tour.motosikletKategorisi);

                    return GestureDetector(
                      onTap: () {
                        // Tıklayınca Detaya Git
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TourDetailScreen(tour: tour, imageUrl: imageUrl)));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5)],
                          border: Border.all(color: Colors.white10)
                        ),
                        child: Row(
                          children: [
                            // 1. SOL TARAFTA RESİM
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                              child: Image.network(
                                imageUrl, 
                                width: 110, 
                                height: 110, 
                                fit: BoxFit.cover
                              ),
                            ),
                            
                            const SizedBox(width: 15),
                            
                            // 2. SAĞ TARAFTA BİLGİLER
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tour.baslik, 
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis, 
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                                    ),
                                    const SizedBox(height: 5),
                                    
                                    // Yeşil Onay Yazısı
                                    const Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                                        SizedBox(width: 5),
                                        Text("Kayıt Onaylandı", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    
                                    const Spacer(),
                                    
                                    // Tarih ve Detay Oku
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("${tour.tarih.day}.${tour.tarih.month}.${tour.tarih.year}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14)
                                      ],
                                    )
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